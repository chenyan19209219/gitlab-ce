# frozen_string_literal: true

class MigrateLegacyUploads < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  DOWNTIME = false
  MIGRATION = 'MigrateLegacyUploads'

  def up
    BackgroundMigrationWorker.perform_async(MIGRATION)
  end

  # not needed
  def down
  end
end
