# frozen_string_literal: true

module ErrorTracking
  class ListSentryProjectsService < ::BaseService
    def execute
      return error('access denied') unless can_read?

      e = project_error_tracking_setting

      unless e.valid?
        return error(e.errors.full_messages.join(', '), :bad_request)
      end

      result = e.list_sentry_projects

      # our results are not yet ready
      unless result
        return error('not ready', :no_content)
      end

      success(projects: result[:projects])
    end

    private

    def project_error_tracking_setting
      e = project.error_tracking_setting
      e.api_url = params[:api_host]
      e.token = params[:token]
      e.enabled = true
      e
    end

    def can_read?
      can?(current_user, :read_sentry_issue, project)
    end
  end
end
