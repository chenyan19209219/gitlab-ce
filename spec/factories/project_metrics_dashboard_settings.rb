# frozen_string_literal: true

FactoryBot.define do
  factory :project_metrics_dashboard_setting, class: ProjectMetricsDashboardSetting do
    project
    external_dashboard_url 'https://grafana.com'
  end
end
