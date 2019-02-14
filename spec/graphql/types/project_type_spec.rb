require 'spec_helper'

describe GitlabSchema.types['Project'] do
  it { expect(described_class).to expose_permissions_using(Types::PermissionTypes::Project) }

  it { expect(described_class.graphql_name).to eq('Project') }

  it { is_expected.to require_graphql_authorizations(:read_project) }

  it { is_expected.to have_graphql_field(:merge_request) }

  it { is_expected.to have_graphql_field(:issues) }

  it { is_expected.to have_graphql_field(:pipelines) }
end
