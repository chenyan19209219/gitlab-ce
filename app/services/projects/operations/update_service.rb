# frozen_string_literal: true

module Projects
  module Operations
    class UpdateService < BaseService
      def execute
        Projects::UpdateService
          .new(project, current_user, project_update_params)
          .execute
      end

      private

      def project_update_params
        attribs = params.slice(:error_tracking_setting_attributes)

        if attribs[:error_tracking_setting_attributes].present?
          attribs[:error_tracking_setting_attributes] =
            construct_error_tracking_setting_params(attribs[:error_tracking_setting_attributes])
        end

        attribs
      end

      def construct_error_tracking_setting_params(settings)
        settings[:api_url] = ErrorTracking::ProjectErrorTrackingSetting.build_api_url_from(
          api_host: settings[:api_host],
          project_slug: settings.dig(:project, :slug),
          organization_slug: settings.dig(:project, :organization_slug)
        )

        settings[:project_name] = settings.dig(:project, :name).presence
        settings[:organization_name] = settings.dig(:project, :organization_name).presence

        settings.slice(
          :api_url,
          :token,
          :enabled,
          :project_name,
          :organization_name
        )
      end
    end
  end
end
