# frozen_string_literal: true

# Searches a projects repository for a metrics dashboard and formats the output.
# Expects any custom dashboards will be located in `.gitlab/dashboards`
module Gitlab
  module MetricsDashboard
    class SystemDashboardService < Gitlab::MetricsDashboard::BaseService
      SYSTEM_DASHBOARD_PATH = 'config/prometheus/common_metrics.yml'

      def self.system_dashboard?(filepath)
        filepath == SYSTEM_DASHBOARD_PATH
      end

      # Returns the base metrics shipped with every GitLab service.
      def get_raw_dashboard(_filepath)
        YAML.load_file(Rails.root.join(SYSTEM_DASHBOARD_PATH))
      end

      def cache_key(_filepath)
        "METRICS_DASHBOARD_#{SYSTEM_DASHBOARD_PATH}"
      end

      def insert_project_metrics
        true
      end

      def all_dashboards
        [{
          path: SYSTEM_DASHBOARD_PATH,
          default: true
        }]
      end
    end
  end
end
