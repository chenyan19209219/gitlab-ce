# frozen_string_literal: true

class AddVariableTypeToCiVariables < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  def up
    %i(ci_group_variables ci_pipeline_schedule_variables ci_pipeline_variables ci_variables).each do |table_name|
      add_column(table_name, :variable_type, :smallint, null: true)
    end
  end

  def down
    %i(ci_group_variables ci_pipeline_schedule_variables ci_pipeline_variables ci_variables).each do |table_name|
      remove_column(table_name, :variable_type)
    end
  end
end
