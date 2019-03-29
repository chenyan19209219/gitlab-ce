# frozen_string_literal: true

require 'spec_helper'

describe Projects::Environments::PrometheusApiController do
  set(:project) { create(:project) }
  set(:environment) { create(:environment, project: project) }
  set(:user) { create(:user) }

  before do
    project.add_reporter(user)
    sign_in(user)
  end

  describe 'GET #proxy' do
    let(:prometheus_proxy_service) { instance_double(Prometheus::ProxyService) }
    let(:prometheus_response) { { status: 200, body: response_body } }
    let(:json_response_body) { JSON.parse(response_body) }

    let(:response_body) do
      "{\"status\":\"success\",\"data\":{\"resultType\":\"scalar\",\"result\":[1553864609.117,\"1\"]}}"
    end

    before do
      allow(Prometheus::ProxyService).to receive(:new)
        .with(environment, 'GET', 'query', anything)
        .and_return(prometheus_proxy_service)

      allow(prometheus_proxy_service).to receive(:execute)
        .and_return(prometheus_response)
      allow(prometheus_response).to receive(:code).and_return(200)
      allow(prometheus_response).to receive(:body).and_return(response_body)
    end

    it 'works' do
      get :proxy, params: environment_params({ proxy_path: 'query', query: '1' })

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to eq(json_response_body)
    end
  end

  private

  def environment_params(params)
    {
      id: environment.id,
      namespace_id: project.namespace,
      project_id: project
    }.merge(params)
  end
end
