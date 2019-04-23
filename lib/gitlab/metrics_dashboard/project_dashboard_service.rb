# frozen_string_literal: true

# Searches a projects repository for a metrics dashboard and formats the output.
# Expects any custom dashboards will be located in `.gitlab/dashboards`
module Gitlab
  module MetricsDashboard
    class ProjectDashboardService < Gitlab::MetricsDashboard::BaseService
      DASHBOARD_ROOT = ".gitlab/dashboards"

      # Searches the project repo for a custom-defined dashboard.
      def get_raw_dashboard(filepath)
        YAML.load(finder.read(filepath))
      end

      def cache_key(filepath)
        "PROJECT_#{project.id}_METRICS_DASHBOARD_#{filepath}"
      end

      def all_dashboards
        finder
          .list_files_for(DASHBOARD_ROOT)
          .map { |filepath| { path: filepath, default: false } }
      end

      def finder
        Gitlab::Template::Finders::RepoTemplateFinder.new(project, DASHBOARD_ROOT, '.yml')
      end
    end
  end
end
