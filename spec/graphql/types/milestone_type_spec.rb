require 'spec_helper'

describe GitlabSchema.types['Milestone'] do
  it { is_expected.to require_graphql_authorizations(:read_milestone) }
end
