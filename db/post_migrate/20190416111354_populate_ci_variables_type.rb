# frozen_string_literal: true

class PopulateCiVariablesType < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  ENV_VAR_VARIABLE_TYPE = 1

  disable_ddl_transaction!

  def up
    %i(ci_group_variables ci_pipeline_schedule_variables ci_pipeline_variables ci_variables).each do |table_name|
      update_column_in_batches(table_name, :variable_type, ENV_VAR_VARIABLE_TYPE) do |table, query|
        query.where(table[:variable_type].eq(nil))
      end
    end
  end

  def down
  end
end
