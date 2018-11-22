module QA
  module Page
    module Clusters
      module Shared
        module Index
          def self.included(base)
            base.view 'app/views/clusters/clusters/_empty_state.html.haml' do
              element :add_kubernetes_cluster_button, "link_to s_('ClusterIntegration|Add Kubernetes cluster')" # rubocop:disable QA/ElementWithPattern
            end
          end

          def add_kubernetes_cluster
            click_on 'Add Kubernetes cluster'
          end
        end
      end
    end
  end
end
