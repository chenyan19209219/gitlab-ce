# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::MetricsDashboard::Finder, :use_clean_rails_memory_store_caching do
  let(:project) { build(:project) }
  let(:environment) { build(:environment) }

  describe '::find' do
    let(:dashboard_schema) { JSON.parse(fixture_file('lib/gitlab/metrics_dashboard/schemas/dashboard.json')) }

    shared_examples_for 'valid dashboard' do |dashboard_path|
      it 'returns a json representation of the dashboard' do
        result = described_class.find(project, environment, dashboard_path)

        expect(result.keys).to contain_exactly(:dashboard, :status)
        expect(result[:status]).to eq(:success)

        expect(JSON::Validator.fully_validate(dashboard_schema, result[:dashboard])).to be_empty
      end
    end

    shared_examples_for 'misconfigured dashboard' do |status_code, dashboard_path|
      it 'returns an appropriate message and status code' do
        result = described_class.find(project, environment, dashboard_path)

        expect(result.keys).to contain_exactly(:message, :http_status, :status)
        expect(result[:status]).to eq(:error)
        expect(result[:http_status]).to eq(status_code)
      end
    end

    context 'when no dashboard is specified' do
      it_behaves_like 'valid dashboard'

      it 'caches the unprocessed dashboard for subsequent calls' do
        expect(YAML).to receive(:load_file).once.and_call_original

        described_class.find(project, environment)
        described_class.find(project, environment)
      end
    end

    context 'when a dashboard is specified' do
      context 'when the dashboard exists' do
        let(:dashboard_yml) { fixture_file('lib/gitlab/metrics_dashboard/sample_dashboard.yml') }
        let(:dashboard_file) { { '.gitlab/dashboards/test.yml' => dashboard_yml } }
        let(:project) { create(:project, :custom_repo, files: dashboard_file) }

        it_behaves_like 'valid dashboard', '.gitlab/dashboards/test.yml'

        it 'caches the unprocessed dashboard for subsequent calls' do
          expect_any_instance_of(Gitlab::MetricsDashboard::ProjectDashboardService)
            .to receive(:get_raw_dashboard)
            .once
            .and_call_original

          described_class.find(project, environment, '.gitlab/dashboards/test.yml')
          described_class.find(project, environment, '.gitlab/dashboards/test.yml')
        end
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
  end
end
