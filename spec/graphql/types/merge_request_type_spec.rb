require 'spec_helper'

describe GitlabSchema.types['MergeRequest'] do
  it { expect(described_class).to expose_permissions_using(Types::PermissionTypes::MergeRequest) }

  it { is_expected.to require_graphql_authorizations(:read_merge_request) }

  it { is_expected.to have_graphql_field(:head_pipeline) }
end
