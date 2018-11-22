module QA
  module Page
    module Clusters
      module Shared
        module Add
          def self.included(base)
            base.view 'app/views/clusters/clusters/new.html.haml' do
              element :add_existing_cluster_button, "Add existing cluster"
            end
          end

          def add_existing_cluster
            click_on 'Add existing cluster'
          end
        end
      end
    end
  end
end
