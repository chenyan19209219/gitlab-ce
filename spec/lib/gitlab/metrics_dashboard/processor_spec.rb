# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::MetricsDashboard::Processor do
  let(:project) { build(:project) }
  let(:dashboard_yml) { YAML.load_file('spec/fixtures/lib/gitlab/metrics_dashboard/sample_dashboard.yml') }

  describe 'process' do
    let(:dashboard) { JSON.parse(described_class.new(dashboard_yml, project).process, symbolize_names: true) }

    context 'when dashboard config corresponds to common metrics' do
      let!(:common_metric) { create(:prometheus_metric, :common, identifier: 'metric_a1') }

      it 'inserts metric ids into the config' do
        target_metric = all_metrics.find { |metric| metric[:id] == 'metric_a1' }

        expect(target_metric).to include(:metric_id)
      end
    end

    context 'when the project has associated metrics' do
      let!(:project_response_metric) { create(:prometheus_metric, project: project, group: :response) }
      let!(:project_system_metric) { create(:prometheus_metric, project: project, group: :system) }
      let!(:project_business_metric) { create(:prometheus_metric, project: project, group: :business) }

      it 'includes project-specific metrics' do
        expect(all_metrics).to include get_metric_details(project_system_metric)
        expect(all_metrics).to include get_metric_details(project_response_metric)
        expect(all_metrics).to include get_metric_details(project_business_metric)
      end

      it 'orders groups by priority and panels by weight' do
        expected_metrics_order = [
          'metric_a2', # group priority 10, panel weight 2
          'metric_a1', # group priority 10, panel weight 1
          'metric_b', # group priority 1, panel weight 1
          project_business_metric.id, # group priority 0, panel weight nil (0)
          project_response_metric.id, # group priority -5, panel weight nil (0)
          project_system_metric.id, # group priority -10, panel weight nil (0)
        ]
        actual_metrics_order = all_metrics.map { |m| m[:id] || m[:metric_id] }

        expect(actual_metrics_order).to eq expected_metrics_order
      end
    end
  end

  private

  def all_metrics
    dashboard[:panel_groups].map do |group|
      group[:panels].map { |panel| panel[:metrics] }
    end.flatten
  end

  def get_metric_details(metric)
    {
      query_range: metric.query,
      unit: metric.unit,
      label: metric.legend,
      metric_id: metric.id
    }
  end
end
