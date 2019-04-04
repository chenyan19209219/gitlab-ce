# frozen_string_literal: true
require 'spec_helper'

describe 'User edit preferences profile' do
  let(:user) { create(:user) }

  before do
    stub_feature_flags(user_time_settings: true)
    sign_in(user)
    visit(profile_preferences_path)
  end

  it 'allows the user to toggle their time format and display preferences' do
    %w[time_format_in_24h time_display_relative].each do |field_selector|
      field = page.find_field("user[#{field_selector}]")
      expect(field).not_to be_checked
      field.click
      expect(field).to be_checked
    end
  end
end
