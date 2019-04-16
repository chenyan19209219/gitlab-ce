require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20190416111354_populate_ci_variables_type.rb')

describe PopulateCiVariablesType, :migration do
  let(:projects) { table(:projects) }
  let(:ci_variables) { table(:ci_variables) }

  it 'populates variable type for legacy CI variables' do
    project = projects.create!(name: 'gitlab', path: 'gitlab-org/gitlab-ce', namespace_id: 1)
    # Skipping ci_group_variables, ci_pipeline_schedule_variables, and ci_pipeline_variables,
    # same update statement is used for all tables.
    ci_variables.create(project_id: project.id, key: 'LEGACY_VARIABLE', value: 'Content goes here')
    ci_variables.create(project_id: project.id, key: 'FILE', value: 'Content goes here', variable_type: Ci::Variable.variable_types['file'])

    migrate!

    file_variable = ci_variables.find_by(key: 'FILE')
    expect(file_variable.variable_type).to eq(Ci::Variable.variable_types['file'])

    legacy_variable = ci_variables.find_by(key: 'LEGACY_VARIABLE')
    expect(legacy_variable.variable_type).to eq(Ci::Variable.variable_types['env_var'])
  end
end
