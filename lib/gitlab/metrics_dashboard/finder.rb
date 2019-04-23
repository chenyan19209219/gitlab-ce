# frozen_string_literal: true

# Searches a projects repository for a metrics dashboard and formats the output.
# Expects any custom dashboards will be located in `.gitlab/dashboards`
module Gitlab
  module MetricsDashboard
    class Finder
      class << self
        def find(project, environment, dashboard_filepath = nil)
          service = if system_dashboard?(dashboard_filepath)
                      system_service(project, environment)
                    else
                      project_service(project, environment)
                    end

          service.get_dashboard(dashboard_filepath)
        end

        def find_all(project, environment)
          system_service(project, environment).all_dashboards
            .+ project_service(project, environment).all_dashboards
        end

        private

        def system_service(project, environment)
          Gitlab::MetricsDashboard::SystemDashboardService.new(
            project,
            environment: environment
          )
        end

        def project_service(project, environment)
          Gitlab::MetricsDashboard::ProjectDashboardService.new(
            project,
            environment: environment
          )
        end

        def system_dashboard?(filepath)
          !filepath || Gitlab::MetricsDashboard::SystemDashboardService.system_dashboard?(filepath)
        end
      end
    end
  end
end
