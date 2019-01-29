# frozen_string_literal: true

class MembersFinder
  attr_reader :project, :current_user, :group

  def initialize(project, current_user)
    @project = project
    @current_user = current_user
    @group = project.group
  end

  def execute(include_descendants: false, include_invited_groups_members: false)
    project_members = project.project_members
    project_members = project_members.non_invite unless can?(current_user, :admin_project, project)

    members_from_groups = []

    if group
      members_from_groups << direct_group_members(include_descendants, include_invited_groups_members)
    end

    if include_invited_groups_members
      members_from_groups << project_invited_groups_members
    end

    if members_from_groups.any?
      distinct_union_of_members(members_from_groups << project_members)
    else
      project_members
    end
  end

  def can?(*args)
    Ability.allowed?(*args)
  end

  private

  def direct_group_members(include_descendants, include_invited_groups_members)
    GroupMembersFinder.new(group).execute(include_descendants: include_descendants).non_invite # rubocop: disable CodeReuse/Finder
  end

  def project_invited_groups_members
    invited_groups_ids_including_ancestors = Gitlab::ObjectHierarchy
      .new(project.invited_groups)
      .base_and_ancestors
      .public_or_visible_to_user(current_user)
      .select(:id)

    GroupMember.with_source_id(invited_groups_ids_including_ancestors)
  end

  def distinct_union_of_members(union_members)
    union = Gitlab::SQL::Union.new(union_members, remove_duplicates: false) # rubocop: disable Gitlab/Union

    sql = distinct_on(union)

    Member.includes(:user).from([Arel.sql("(#{sql}) AS #{Member.table_name}")]) # rubocop: disable CodeReuse/ActiveRecord
  end

  def distinct_on(union)
    # We're interested in a list of members without duplicates by user_id.
    # We prefer project members over group members, project members should go first.
    if Gitlab::Database.postgresql?
      <<~SQL
          SELECT DISTINCT ON (user_id, invite_email) member_union.*
          FROM (#{union.to_sql}) AS member_union
          ORDER BY user_id,
            invite_email,
            CASE
              WHEN type = 'ProjectMember' THEN 1
              WHEN type = 'GroupMember' THEN 2
              ELSE 3
            END
      SQL
    else
      # Older versions of MySQL do not support window functions (and DISTINCT ON is postgres-specific).
      <<~SQL
          SELECT t1.*
          FROM (#{union.to_sql}) AS t1
          JOIN (
            SELECT
              COALESCE(user_id, -1) AS user_id,
              COALESCE(invite_email, 'NULL') AS invite_email,
              MIN(CASE WHEN type = 'ProjectMember' THEN 1 WHEN type = 'GroupMember' THEN 2 ELSE 3 END) AS type_number
            FROM
            (#{union.to_sql}) AS t3
            GROUP BY COALESCE(user_id, -1), COALESCE(invite_email, 'NULL')
          ) AS t2 ON COALESCE(t1.user_id, -1) = t2.user_id
                 AND COALESCE(t1.invite_email, 'NULL') = t2.invite_email
                 AND CASE WHEN t1.type = 'ProjectMember' THEN 1 WHEN t1.type = 'GroupMember' THEN 2 ELSE 3 END = t2.type_number
      SQL
    end
  end
end
