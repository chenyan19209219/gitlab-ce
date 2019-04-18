# frozen_string_literal: true

# Searches a projects repository for a metrics dashboard and formats the output.
# Expects any custom dashboards will be located in `.gitlab/dashboards`
module Gitlab
  module MetricsDashboard
    class Service < ::BaseService
      DASHBOARD_ROOT = ".gitlab/dashboards"
      SYSTEM_DASHBOARD_PATH = 'config/prometheus/common_metrics.yml'

      # Returns a DB-supplemented json representation of a
      # dashboard config file.
      def get_dashboard(filepath = nil)
        unless Feature.enabled?(:environment_metrics_show_multiple_dashboards, project)
          filepath = SYSTEM_DASHBOARD_PATH
        end

        filepath ||= SYSTEM_DASHBOARD_PATH
        dashboard = process_dashboard(filepath)

        success(dashboard: dashboard)
      rescue Gitlab::MetricsDashboard::Stages::BaseStage::DashboardLayoutError => e
        error(e.message, :unprocessable_entity)
      rescue Gitlab::Template::Finders::RepoTemplateFinder::FileNotFoundError => e
        error("Requested dashboard at #{filepath} does not exist", :not_found)
      end

      # Returns a summary array of available dashboards for
      # the project.
      # @return [Array<Hash>>] [{ path: String, default: Boolean }, ...]
      def all_dashboards
        all_project_dashboards + all_system_dashboards
      end

      private

      # Returns an un-processed dashboard from the cache
      def get_raw_dashboard(filepath)
        Rails.cache.fetch(cache_key(filepath)) do
          next raw_system_dashboard if is_system_dashboard?(filepath)

          raw_project_dashboard(filepath)
        end
      end

      # Returns the base metrics shipped with every GitLab service.
      def raw_system_dashboard
        YAML.load_file(Rails.root.join(SYSTEM_DASHBOARD_PATH))
      end

      # Searches the project repo for a custom-defined dashboard.
      def raw_project_dashboard(filepath)
        YAML.load(finder.read(filepath))
      end

      # Returns a new dashboard Hash, supplemented with DB info
      def process_dashboard(filepath)
        raw_dashboard = get_raw_dashboard(filepath)
        insert_project_metrics = is_system_dashboard?(filepath)

        Processor
          .new(project, params[:environment])
          .process(raw_dashboard, insert_project_metrics)
      end

      def is_system_dashboard?(filepath)
        filepath == SYSTEM_DASHBOARD_PATH
      end

      def all_project_dashboards
        finder
          .list_files_for(DASHBOARD_ROOT)
          .map { |filepath| { path: filepath, default: false } }
      end

      def all_system_dashboards
        [{
          path: SYSTEM_DASHBOARD_PATH,
          default: true
        }]
      end

      def finder
        Gitlab::Template::Finders::RepoTemplateFinder.new(project, DASHBOARD_ROOT, '.yml')
      end

      def cache_key(filepath)
        return "METRICS_DASHBOARD_#{SYSTEM_DASHBOARD_PATH}" if is_system_dashboard?(filepath)

        "PROJECT_#{project.id}_METRICS_DASHBOARD_#{filepath}"
      end
    end
  end
end
