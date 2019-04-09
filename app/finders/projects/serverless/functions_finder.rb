# frozen_string_literal: true

module Projects
  module Serverless
    class FunctionsFinder
      def initialize(project)
        @clusters = project.clusters
        @project = project
      end

      def execute
        knative_services.flatten.compact
      end

      def installed?
        @clusters.with_knative_installed.exists? || knative_detected?
      end

      def knative_detected?
        @clusters.any? { |c| c.knative_services_finder.knative_detected? }
      end

      def service(environment_scope, name)
        knative_service(environment_scope, name)&.first
      end

      def invocation_metrics(environment_scope, name)
        return unless prometheus_adapter&.can_query?

        cluster = @clusters.find do |c|
          environment_scope == c.environment_scope
        end

        func = ::Serverless::Function.new(@project, name, cluster.platform_kubernetes&.actual_namespace)
        prometheus_adapter.query(:knative_invocation, func)
      end

      def has_prometheus?(environment_scope)
        @clusters.any? do |cluster|
          environment_scope == cluster.environment_scope && cluster.application_prometheus_available?
        end
        true
      end

      private

      def knative_service(environment_scope, name)
        @clusters.map do |cluster|
          next if environment_scope != cluster.environment_scope

          services = cluster
            .knative_services_finder
            .services
            .select { |svc| svc["metadata"]["name"] == name }

          add_metadata(cluster, services).first unless services.nil?
        end
      end

      def knative_services
        @clusters.map do |cluster|
          services = cluster
          .knative_services_finder
          .services

          add_metadata(cluster, services) unless services.nil?
        end
      end

      def add_metadata(cluster, services)
        services.each do |s|
          s["environment_scope"] = cluster.environment_scope
          s["cluster_id"] = cluster.id

          if services.length == 1
            s["podcount"] = cluster
            .knative_services_finder
            .service_pod_details(s["metadata"]["name"])
            .length
          end
        end
      end

      # rubocop: disable CodeReuse/ServiceClass
      def prometheus_adapter
        @prometheus_adapter ||= ::Prometheus::AdapterService.new(@project).prometheus_adapter
      end
      # rubocop: enable CodeReuse/ServiceClass
    end
  end
end
