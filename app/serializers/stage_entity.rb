# frozen_string_literal: true

class StageEntity < Grape::Entity
  include RequestAwareEntity

  expose :name

  expose :title do |stage|
    "#{stage.name}: #{detailed_status.label}"
  end

  expose :groups,
    if: -> (_, opts) { opts[:grouped] },
    with: JobGroupEntity

  expose :latest_statuses,
    if: -> (_, opts) { opts[:details] },
    with: JobEntity do |stage|
    latest_statuses
  end

  expose :retried,
         if: -> (_, opts) { opts[:retried] },
         with: JobEntity do |stage|
    retried_statuses
  end

  expose :detailed_status, as: :status, with: DetailedStatusEntity

  expose :path do |stage|
    project_pipeline_path(
      stage.pipeline.project,
      stage.pipeline,
      anchor: stage.name)
  end

  expose :dropdown_path do |stage|
    stage_project_pipeline_path(
      stage.pipeline.project,
      stage.pipeline,
      stage: stage.name,
      format: :json)
  end

  expose :play_manual_details,
    if: -> (status, _) { detailed_status.has_manual_builds? },
    with: Stages::PlayManualEntity

  private

  alias_method :stage, :object

  def detailed_status
    @detailed_status ||= stage.detailed_status(request.current_user)
  end

  alias_method :play_manual_details, :detailed_status

  def grouped_statuses
    @grouped_statuses ||= stage.statuses.latest_ordered.group_by(&:status)
  end

  def grouped_retried_statuses
    @grouped_retried_statuses ||= stage.statuses.retried_ordered.group_by(&:status)
  end

  def latest_statuses
    HasStatus::ORDERED_STATUSES.map do |ordered_status|
      grouped_statuses.fetch(ordered_status, [])
    end.flatten
  end

  def retried_statuses
    HasStatus::ORDERED_STATUSES.map do |ordered_status|
      grouped_retried_statuses.fetch(ordered_status, [])
    end.flatten
  end
end
