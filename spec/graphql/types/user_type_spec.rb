require 'spec_helper'

describe GitlabSchema.types['User'] do
  it { is_expected.to require_graphql_authorizations(:read_user) }
end
