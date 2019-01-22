# frozen_string_literal: true

module ErrorTracking
  class ListSentryProjectsService < ::BaseService
    def execute
      return error('not enabled') unless enabled?
      return error('access denied') unless can_read?

      result = project_error_tracking_setting.list_sentry_projects

      # our results are not yet ready
      unless result
        return error('not ready', :no_content)
      end

      success(projects: result[:projects])
    end

    private

    def project_error_tracking_setting
      project.error_tracking_setting
    end

    def enabled?
      project_error_tracking_setting&.enabled?
    end

    def can_read?
      can?(current_user, :read_sentry_issue, project)
    end
  end
end
