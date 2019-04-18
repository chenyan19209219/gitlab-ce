# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddFieldsToUserPreferences < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false

  def up
    add_column_with_default(:user_preferences, :timezone, :string, default: 'UTC')
    add_column_with_default(:user_preferences, :time_display, :boolean, default: false)
    add_column_with_default(:user_preferences, :time_format, :boolean, default: false)
  end

  def down
    remove_column(:user_preferences, :timezone)
    remove_column(:user_preferences, :time_display)
    remove_column(:user_preferences, :time_format)
  end
end
