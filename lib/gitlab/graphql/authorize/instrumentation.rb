# frozen_string_literal: true

module Gitlab
  module Graphql
    module Authorize
      class Instrumentation
        # Replace the resolver for the field with one that will only return the
        # resolved object if the permissions check is successful.
        #
        # Collections are not supported. Apply permissions checks for those at the
        # database level instead, to avoid loading superfluous data from the DB
        def instrument(_type, field)
          service = AuthorizeFieldService.new(field)

          if service.authorization_checks?
            field.redefine { resolve(service.authorized_resolve) }
          else
            field
          end
        end
      end
    end
  end
end
