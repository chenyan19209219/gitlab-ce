# frozen_string_literal: true

module FormHelper
  def form_errors(model, type: 'form')
    return unless model.errors.any?

    render_form_errors(model.errors.full_messages, type)
  end

  def base_form_errors(model)
    return unless invalid_attributes(model).any?

    error_messages = invalid_attributes(model).flat_map do |attribute|
      model.errors.full_messages_for(attribute.to_sym)
    end

    render_form_errors(error_messages.flatten, 'form')
  end

  def issue_assignees_dropdown_options
    {
      toggle_class: 'js-user-search js-assignee-search js-multiselect js-save-user-data',
      title: 'Select assignee',
      filter: true,
      dropdown_class: 'dropdown-menu-user dropdown-menu-selectable dropdown-menu-assignee',
      placeholder: 'Search users',
      data: {
        first_user: current_user&.username,
        null_user: true,
        current_user: true,
        project_id: @project&.id,
        field_name: 'issue[assignee_ids][]',
        default_label: 'Unassigned',
        'max-select': 1,
        'dropdown-header': 'Assignee',
        multi_select: true,
        'input-meta': 'name',
        'always-show-selectbox': true,
        current_user_info: UserSerializer.new.represent(current_user)
      }
    }
  end

  private

  def render_form_errors(full_messages, type)
    pluralized = 'error'.pluralize(full_messages.count)
    headline   = "The #{type} contains the following #{pluralized}:"

    error_explanation_div(headline, full_messages)
  end

  def error_explanation_div(headline, error_messages)
    content_tag(:div, class: 'alert alert-danger', id: 'error_explanation') do
      content_tag(:h4, headline) <<
        content_tag(:ul) do
          error_messages
            .map { |msg| content_tag(:li, msg) }
            .join
            .html_safe
        end
    end
  end

  def invalid_attributes(model)
    return [] unless model.errors.any?

    model.attribute_names.select { |attribute| model.errors[attribute].present? }
  end
end
