# frozen_string_literal: true

module ContextualSidebarHelper
  def collapsed_sidebar?
    cookies["sidebar_collapsed"] == "true"
  end


  def contextual_sidebar_css_class
    collapsed_sidebar? ? collapsed_css_class : ''
  end

  private

  def collapsed_css_class
    'sidebar-collapsed js-sidebar-collapsed'
  end
end
