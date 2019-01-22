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

        attribs[:api_url] = attribs[:api_url].presence
        attribs[:token] = attribs[:token].presence

        attribs
      end
    end
  end
end
