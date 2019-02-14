require 'spec_helper'

describe GitlabSchema.types['Pipeline'] do
  it { is_expected.to require_graphql_authorizations(:read_pipeline) }
end
