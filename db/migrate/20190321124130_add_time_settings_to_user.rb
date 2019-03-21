# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddTimeSettingsToUser < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false

  def up
    add_column_with_default(:users, :timezone, :string, default: 'UTC')
    add_column_with_default(:users, :time_display, :boolean, default: false)
    add_column_with_default(:users, :time_format, :boolean, default: false)
  end

  def down
    remove_column(:users, :timezone)
    remove_column(:users, :time_display)
    remove_column(:users, :time_format)
  end
end
