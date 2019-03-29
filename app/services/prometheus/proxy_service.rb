# frozen_string_literal: true

module Prometheus
  class ProxyService
    include ReactiveCaching

    self.reactive_cache_key = ->(service) { service.cache_key }
    self.reactive_cache_lease_timeout = 30.seconds
    self.reactive_cache_refresh_interval = 30.seconds
    self.reactive_cache_lifetime = 1.minute
    self.reactive_cache_worker_finder = ->(_id, *args) { from_cache(*args) }

    attr_accessor :prometheus_owner, :path, :params

    def self.from_cache(prometheus_owner_class_name, prometheus_owner_id, path, params)
      prometheus_owner_class = begin
        prometheus_owner_class_name.constantize
      rescue NameError
        nil
      end
      return unless prometheus_owner_class

      prometheus_owner = prometheus_owner_class.find(prometheus_owner_id)

      new(prometheus_owner, path, params)
    end

    # prometheus_owner can be any model which responds to .prometheus_adapter
    # like environment.
    def initialize(prometheus_owner, path, params)
      @prometheus_owner = prometheus_owner
      @path = path
      @params = params
    end

    def id
      nil
    end

    def execute
      return no_prometheus_response unless prometheus_adapter.can_query?

      with_reactive_cache(*cache_key) do |result|
        result
      end
    end

    def cache_key
      [@prometheus_owner.class.name, @prometheus_owner.id, @path, @params.stringify_keys]
    end

    private

    def no_prometheus_response
      { status: 'error', message: 'No prometheus server found' }
    end

    def calculate_reactive_cache(prometheus_owner_class_name, prometheus_owner_id, path, params)
      @prometheus_owner = Kernel.const_get(prometheus_owner_class_name).find(prometheus_owner_id)

      return no_prometheus_response unless prometheus_adapter.can_query?

      case path
      when 'query'
        {
          status: 'success',
          data: prometheus_client_wrapper.query(params['query'], time: params['time'] || Time.now, only_result: false)
        }
      when 'query_range'
        {
          status: 'success',
          data: prometheus_client_wrapper.query_range(query, start: params['start'], stop: params['end'], only_result: false)
        }
      else
        { status: 'error', message: 'Not supported' }
      end
    rescue Gitlab::PrometheusClient::Error => err
      { status: 'error', message: err.message }
    end

    def prometheus_adapter
      @prometheus_owner.prometheus_adapter
    end

    def prometheus_client_wrapper
      prometheus_adapter.prometheus_client_wrapper
    end
  end
end
