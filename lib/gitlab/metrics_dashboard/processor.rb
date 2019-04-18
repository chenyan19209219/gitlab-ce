# frozen_string_literal: true

module Gitlab
  module MetricsDashboard
    # Responsible for processesing a dashboard hash, inserting
    # relevant DB records & sorting for proper rendering in
    # the UI. These includes shared metric info, custom metrics
    # info, and alerts (only in EE).
    class Processor
      SYSTEM_SEQUENCE = [
        Stages::CommonMetricsInserter,
        Stages::ProjectMetricsInserter,
        Stages::Sorter
      ].freeze

      PROJECT_SEQUENCE = [
        Stages::CommonMetricsInserter,
        Stages::Sorter
      ].freeze

      def initialize(project, environment)
        @project = project
        @environment = environment
      end

      # Returns a new dashboard hash with the results of
      # running transforms on the dashboard.
      def process(dashboard, insert_project_metrics)
        dashboard = dashboard.deep_transform_keys(&:to_sym)

        stage_params = [@project, @environment]
        sequence(insert_project_metrics).each { |stage| stage.new(*stage_params).transform!(dashboard) }

        dashboard
      end

      private

      def sequence(insert_project_metrics)
        insert_project_metrics ? SYSTEM_SEQUENCE : PROJECT_SEQUENCE
      end
    end
  end
end
