# frozen_string_literal: true

class Projects::Environments::PrometheusApiController < Projects::ApplicationController
  before_action :environment

  # TODO: This should probably be limited to reporters and above. Introduce new policy
  # called read_prometheus (like read_environment)?

  # TODO: filter params

  def proxy
    result = Prometheus::ProxyService.new(environment, request.method, params[:proxy_path], params).execute

    if result.nil?
      render status: :accepted, json: {
        status: 'processing',
        message: 'Not ready yet. Try again later.'
      }
      return
    end

    if result[:status] == :success
      render status: result[:http_status], json: result[:body]
    else
      render status: result[:http_status] || :bad_request, json: {
          status: result[:status],
          message: result[:message]
        }
    end
  end

  private

  def environment
    @environment ||= project.environments.find(params[:id])
  end
end
