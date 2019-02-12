# frozen_string_literal: true

module Projects
  module Operations
    class UpdateService < BaseService
      def execute
        setting = project.error_tracking_setting

        result = if setting.nil?
                   project.create_error_tracking_setting(
                     error_tracking_params.merge(project_id: project.id)
                   )
                 else
                   setting.update(error_tracking_params)
                 end

        if result
          success
        else
          update_failed!
        end
      end

      private

      def update_failed!
        model_errors = project.error_tracking_setting&.errors&.full_messages
        error_message = model_errors.presence || 'Error tracking settings could not be updated!'

        error(error_message)
      end

      def error_tracking_params
        settings = params[:error_tracking_setting_attributes]
        return {} if settings.blank?

        api_url = ErrorTracking::ProjectErrorTrackingSetting.build_api_url_from(
          api_host: settings[:api_host],
          project_slug: settings.dig(:project, :slug),
          organization_slug: settings.dig(:project, :organization_slug)
        )

        {
          api_url: api_url,
          token: settings[:token],
          enabled: settings[:enabled],
          project_name: settings.dig(:project, :name),
          organization_name: settings.dig(:project, :organization_name)
        }
      end
    end
  end
end
