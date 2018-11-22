# frozen_string_literal: true

module QA
  module Page
    module Group
      class Menu < Page::Base
        view 'app/views/layouts/nav/sidebar/_group.html.haml' do
          element :group_sidebar
          element :kubernetes_kubernetes_link
        end

        def click_kubernetes_kubernetes
          within_sidebar do
            click_link(:kubernetes_kubernetes_link)
          end
        end

        private

        def within_sidebar
          within_element(:group_sidebar) do
            yield
          end
        end
      end
    end
  end
end
