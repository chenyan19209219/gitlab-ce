# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::MetricsDashboard::Service, :use_clean_rails_memory_store_caching do
  let(:project) { build(:project) }
  let(:environment) { build(:environment) }

  let(:service) { described_class.new(project, environment) }

  describe 'get_dashboard' do
    let(:dashboard_schema) { JSON.parse(fixture_file('lib/gitlab/metrics_dashboard/schemas/dashboard.json')) }

    shared_examples_for 'processed dashboard' do |dashboard_path|
      it 'returns a json representation of the system dashboard' do
        result = service.get_dashboard(dashboard_path)

        expect(result.keys).to contain_exactly(:dashboard, :status)
        expect(result[:status]).to eq(:success)

        expect(JSON::Validator.fully_validate(dashboard_schema, result[:dashboard])).to be_empty
      end

      it 'caches the raw dashboard for subsequent calls' do
        expected_method = dashboard_path ? :raw_project_dashboard : :raw_system_dashboard

        expect(service).to receive(expected_method).once.and_call_original

        service.get_dashboard(dashboard_path)
        service2 = described_class.new(project, environment)

        expect(service2).not_to receive(expected_method)

        service2.get_dashboard(dashboard_path)
      end
    end

    shared_examples_for 'misconfigured dashboard' do |status_code, dashboard_path|
      it 'returns an appropriate message and status code' do
        result = service.get_dashboard(dashboard_path)

        expect(result.keys).to contain_exactly(:message, :http_status, :status)
        expect(result[:status]).to eq(:error)
        expect(result[:http_status]).to eq(status_code)
      end
    end

    context 'when no dashboard is specified' do
      it_behaves_like 'processed dashboard'
    end

    context 'when a dashboard is specified' do
      context 'when the dashboard exists' do
        let(:dashboard_yml) { fixture_file('lib/gitlab/metrics_dashboard/sample_dashboard.yml') }
        let(:dashboard_file) { { '.gitlab/dashboards/test.yml' => dashboard_yml } }
        let(:project) { create(:project, :custom_repo, files: dashboard_file) }

        it_behaves_like 'processed dashboard', '.gitlab/dashboards/test.yml'
      end

      context 'when the dashboard does not exist' do
        it_behaves_like 'misconfigured dashboard', :not_found, '.gitlab/dashboards/test.yml'
      end
    end

    context 'when the dashboard is configured incorrectly' do
      before do
        allow(YAML).to receive(:load_file).and_return({})
      end

      it_behaves_like 'misconfigured dashboard', :unprocessable_entity
    end

    context 'when the multiple dashboards feature is disabled' do
      before do
        stub_feature_flags(environment_metrics_show_multiple_dashboards: false)
      end

      context 'when no dashboard is specified' do
        it_behaves_like 'processed dashboard'
      end

      context 'when a dashboard is specified' do
        let(:dashboard_path) { '.gitlab/dashboards/test.yml' }

        it 'returns the system dashboard regardless' do
          system_dashboard = service.get_dashboard
          fetched_dashboard = service.get_dashboard(dashboard_path)

          expect(fetched_dashboard).to eq(system_dashboard)
        end
      end
    end
  end
end
