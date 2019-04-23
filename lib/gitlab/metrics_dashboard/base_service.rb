# frozen_string_literal: true

# Searches a projects repository for a metrics dashboard and formats the output.
# Expects any custom dashboards will be located in `.gitlab/dashboards`
module Gitlab
  module MetricsDashboard
    class BaseService < ::BaseService
      def get_dashboard(filepath = nil)
        dashboard = process_dashboard(raw_dashboard(filepath))

        success(dashboard: dashboard)
      rescue Gitlab::MetricsDashboard::Stages::BaseStage::DashboardLayoutError => e
        error(e.message, :unprocessable_entity)
      rescue Gitlab::Template::Finders::RepoTemplateFinder::FileNotFoundError => e
        error("Requested dashboard at #{filepath} does not exist", :not_found)
      end

      # Returns an un-processed dashboard from the cache
      def raw_dashboard(filepath)
        Rails.cache.fetch(cache_key(filepath)) { get_raw_dashboard(filepath) }
      end

      # Returns a new dashboard Hash, supplemented with DB info
      def process_dashboard(dashboard)
        processor.process(dashboard, insert_project_metrics)
      end

      def processor
        Processor.new(project, params[:environment])
      end

      def insert_project_metrics
        false
      end
    end
  end
end
