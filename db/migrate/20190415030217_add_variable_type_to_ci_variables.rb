# frozen_string_literal: true

class AddVariableTypeToCiVariables < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  DOWNTIME = false
  ENV_VAR_VARIABLE_TYPE = 1

  def up
    %i(ci_group_variables ci_pipeline_schedule_variables ci_pipeline_variables ci_variables).each do |table_name|
      add_column_with_default(table_name, :variable_type, :smallint, default: ENV_VAR_VARIABLE_TYPE)
    end
  end

  def down
    %i(ci_group_variables ci_pipeline_schedule_variables ci_pipeline_variables ci_variables).each do |table_name|
      remove_column(table_name, :variable_type)
    end
  end
end
