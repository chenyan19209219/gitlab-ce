# frozen_string_literal: true

require 'spec_helper'

describe Prometheus::ProxyService do
  include ReactiveCachingHelpers
  include PrometheusHelpers

  describe 'execute' do
    let(:environment) { create(:environment) }

    subject { described_class.new(environment, 'GET', 'query', { query: '1' }) }

    context 'when prometheus_adapter is nil' do
      before do
        allow(environment).to receive(:prometheus_adapter).and_return(nil)
      end

      it 'should return error' do
        expect(subject.execute).to eq({
          status: :error,
          message: 'No prometheus server found',
          http_status: :service_unavailable
        })
      end
    end

    context 'calls prometheus_client' do
      let(:prometheus_url) {"https://prometheus.invalid.example.com/api/v1/query?query=1"}
      let(:prometheus_adapter) { instance_double(PrometheusService) }
      let(:prometheus_client) { instance_double(Gitlab::PrometheusClient) }
      let(:rest_client_response) { instance_double(RestClient::Response) }

      let(:response_body) do
        "{\"status\":\"success\",\"data\":{\"resultType\":\"scalar\",\"result\":[1553864609.117,\"1\"]}}"
      end

      before do
        synchronous_reactive_cache(subject)

        allow(environment).to receive(:prometheus_adapter).and_return(prometheus_adapter)
        allow(prometheus_adapter).to receive(:can_query?).and_return(true)
        allow(prometheus_adapter).to receive(:prometheus_client_wrapper).and_return(prometheus_client)
        allow(prometheus_client).to receive(:proxy)
          .with('query', { 'query' => '1' }).and_return(rest_client_response)
        allow(rest_client_response).to receive(:code).and_return(200)
        allow(rest_client_response).to receive(:body).and_return(response_body)
      end

      it 'works' do
        expect(subject.execute).to eq({
          http_status: 200,
          body: "{\"status\":\"success\",\"data\":{\"resultType\":\"scalar\",\"result\":[1553864609.117,\"1\"]}}"
        })
      end
    end
  end
end
