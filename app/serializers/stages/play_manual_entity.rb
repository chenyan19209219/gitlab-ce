# frozen_string_literal: true

class Stages::PlayManualEntity < Grape::Entity
  expose :action_icon, as: :icon
  expose :action_button_title, as: :button_title
  expose :action_title, as: :title
  expose :action_path, as: :path
  expose :action_method, as: :method
end
