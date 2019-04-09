# frozen_string_literal: true
module Clusters
  class Cluster
    class KnativeServicesFinder
      include ReactiveCaching

      self.reactive_cache_key = ->(finder) { finder.cache_key }
      self.reactive_cache_worker_finder = ->(_id, *args) { from_cache(*args) }

      attr_reader :cluster

      def initialize(cluster)
        @cluster = cluster
      end

      def clear_cache!
        clear_reactive_cache!(*cache_key)
      end

      def self.from_cache(_class_name, cluster_id)
        cluster = Clusters::Cluster.find(cluster_id)
        new(cluster)
      end

      def calculate_reactive_cache(*)
        # read_services calls knative_client.discover implicitily. If we stop
        # detecting services but still want to detect knative, we'll need to
        # explicitily call: knative_client.discover
        #
        # We didn't create it separately to avoid 2 cluster requests.
        ksvc = read_services

        { services: ksvc, pods: read_pods, knative_detected: knative_client.discovered }
      end

      def services
        return [] unless search_namespace

        with_reactive_cache(*cache_key) do |data|
          services_json = data[:services]

          services_json&.select do |service|
            service.dig('metadata', 'namespace') == search_namespace
          end
        end || []
      end

      def cache_key
        [@cluster.class.model_name.singular, @cluster.id]
      end

      def service_pod_details(service)
        with_reactive_cache(*cache_key) do |data|
          data[:pods].select { |pod| filter_pods(pod, service) }
        end
      end

      def knative_detected?
        with_reactive_cache(*cache_key) do |data|
          data[:knative_detected]
        end
      end

      private

      def knative_client
        cluster.kubeclient.knative_client
      end

      def search_namespace
        cluster.platform_kubernetes&.actual_namespace
      end

      def filter_pods(pod, service)
        pod["metadata"]["namespace"] == search_namespace &&
          pod["metadata"]["labels"]["serving.knative.dev/service"] == service
      end

      def read_services
        knative_client.get_services.as_json
      rescue Kubeclient::ResourceNotFoundError
        []
      end

      def read_pods
        cluster.kubeclient.core_client.get_pods.as_json
      end

      def id
        nil
      end
    end
  end
end
