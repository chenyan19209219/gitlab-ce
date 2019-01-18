# frozen_string_literal: true

class AddColumnsProjectErrorTrackingSettings < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :project_error_tracking_settings, :project_name, :string
    add_column :project_error_tracking_settings, :organization_name, :string
  end
end
