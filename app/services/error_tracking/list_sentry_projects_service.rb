# frozen_string_literal: true

module ErrorTracking
  class ListSentryProjectsService < ::BaseService
    def execute
      return error('access denied') unless can_read?

      e = project_error_tracking_setting

      unless e.valid?
        return error(e.errors.full_messages.join(', '), :bad_request)
      end

      begin
        result = e.list_sentry_projects
      rescue Sentry::Client::Error => e
        return error(e.message, :bad_request)
      rescue Sentry::Client::SentryError => e
        return error(e.message, :unprocessable_entity)
      end

      success(projects: result[:projects])
    end

    private

    def project_error_tracking_setting
      e = project.error_tracking_setting || project.build_error_tracking_setting

      e.api_url = ErrorTracking::ProjectErrorTrackingSetting.build_api_url_from(
        api_host: params[:api_host],
        organization_slug: nil,
        project_slug: nil
      )
      e.token = params[:token]
      e.enabled = true

      e
    end

    def can_read?
      can?(current_user, :read_sentry_issue, project)
    end
  end
end
