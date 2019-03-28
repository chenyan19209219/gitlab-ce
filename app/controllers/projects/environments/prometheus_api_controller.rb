# frozen_string_literal: true

class Projects::PrometheusAPIController < Projects::ApplicationController
  before_action :environment

  # TODO: This should probably be limited to reporters and above. Introduce new policy
  # called read_prometheus (like read_environment)?

  def prometheus
    result = Prometheus::ProxyService.new(environment, params[:proxy_path], params).execute

    if result[:status] == 'success'
      render json: {
        status: result[:status],
        warnings: result[:warnings],
        data: result[:data]
      }
    else
      render json: {
        status: result[:status],
        data: result[:data],
        errorType: result[:errorType],
        error: result[:error],
        warnings: result[:warnings],
        message: result[:message]
      }
    end
  end

  private

  def environment
    @environment ||= project.environments.find(params[:id])
  end
end
