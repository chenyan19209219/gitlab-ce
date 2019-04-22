# frozen_string_literal: true

class AddDashboardSettings < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :project_metrics_dashboard_settings, id: :int, primary_key: :project_id, default: nil do |t|
      t.timestamps_with_timezone
      t.string :external_dashboard_url
      t.foreign_key :projects, column: :project_id, on_delete: :cascade
    end
  end
end
