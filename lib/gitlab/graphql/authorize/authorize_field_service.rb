# frozen_string_literal: true

module Gitlab
  module Graphql
    module Authorize
      class AuthorizeFieldService
        def initialize(field)
          @field = field
          @old_resolve_proc = @field.resolve_proc
        end

        def authorization_checks?
          authorization_checks.present?
        end

        def authorized_resolve
          proc do |obj, args, ctx|
            resolved_object = @old_resolve_proc.call(obj, args, ctx)

            authorized = authorization_checks.all? do |authorization_check|
              # Authorization checks can be a Symbol (i.e.: :read_project)
              # or a Proc.
              #
              # If the check is a Symbol, turn this into an Ability check.
              if authorization_check.is_a?(Symbol)
                ability_subject = subject_for_ability(resolved_object, obj)
                Ability.allowed?(ctx[:current_user], authorization_check, ability_subject)
              elsif authorization_check.is_a?(Proc)
                authorization_check.call(obj, args, ctx).present?
              else
                raise NotImplementedError, "Cannot handle authorization for #{authorization_check.inspect}"
              end
            end

            if authorized
              resolved_object
            end
          end
        end

        private

        def authorization_checks
          @authorization_checks ||= type_authorization_checks + field_authorization_checks
        end

        # Returns any authorize metadata from the return type of @field
        def type_authorization_checks
          type = @field.metadata[:type_class]&.type
          if type.respond_to?(:authorize) && type.authorize
            type.authorize.flatten
          else
            []
          end
        end

        # Returns any authorize metadata from the field
        def field_authorization_checks
          Array.wrap(@field.metadata[:authorize])
        end

        # Returns the subject that will be used in the Ability check:
        # Ability.allow?(user, :permission, subject)
        #
        # For most occasions, whether or not the field's type is something
        # subclassed from Types::BaseObject is what should determine what
        # the subject is.
        #
        # For example, the subject here should be the MergeRequest:
        #
        # class ProjectType
        #   field :mergeRequest, Types::MergeRequest, authorize: :read_merge_request
        # end
        #
        # But for this Scalar-type field, the subject should be the Project:
        #
        # class ProjectType
        #   field :id, GraphQL::ID_TYPE, authorize: :read_project
        # end
        #
        # If this is ever not correct, a Proc can be used with authorize to
        # do a custom authorization
        def subject_for_ability(resolved_object, obj)
          # Load the element if it wasn't loaded by BatchLoader yet
          resolved_object = resolved_object.sync if resolved_object.respond_to?(:sync)
          return_type = @field.metadata[:type_class].type

          if return_type.is_a?(Class) && return_type < Types::BaseObject
            resolved_object
          else
            obj.object
          end
        end
      end
    end
  end
end
