# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::MetricsDashboard::Service, :use_clean_rails_memory_store_caching do
  let(:project) { build(:project) }
  let(:environment) { build(:environment) }

  describe 'get_dashboard' do
    let(:dashboard_schema) { JSON.parse(fixture_file('lib/gitlab/metrics_dashboard/schemas/dashboard.json')) }

    it 'returns a json representation of the environment dashboard' do
      result = described_class.new(project, environment).get_dashboard

      expect(result.keys).to contain_exactly(:dashboard, :status)
      expect(result[:status]).to eq(:success)

      expect(JSON::Validator.fully_validate(dashboard_schema, result[:dashboard])).to be_empty
    end

    it 'caches the dashboard for subsequent calls' do
      expect(YAML).to receive(:load_file).once.and_call_original

      described_class.new(project, environment).get_dashboard
      described_class.new(project, environment).get_dashboard
    end
  end
end
