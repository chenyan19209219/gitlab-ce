require 'spec_helper'

describe 'New project' do
  include Select2Helper

  let(:user) { create(:admin) }

  before do
    sign_in(user)
  end

  def select_project_visibility(visibility_level, value)
    choose(visibility_level)
    expect(find_field("project[visibility_level]", checked: true).value.to_i).to eq(value)
  end

  def select_license(template)
    page.within('.js-license-selector-wrap') do
      click_button 'Apply a license template'
      click_link template
      wait_for_requests
    end
  end

  def has_additional_fields(visible = true)
    [
      { text: 'Project description', sel: 'label' },
      { text: 'Project avatar', sel: 'label' },
      { text: 'License', sel: 'label' },
      { text: 'Features', sel: 'label' },
      { text: 'Issues', sel: 'label' },
      { text: 'Repository', sel: 'label' },
      { text: 'Wiki', sel: 'label' },
      { text: 'Snippets', sel: 'label' },
      { text: 'Lightweight issue tracking system for this project', sel: 'span' },
      { text: 'View and edit files in this project', sel: 'span' },
      { text: 'Pages for project documentation', sel: 'span' },
      { text: 'Share code pastes with others out of Git repository', sel: 'span' }
    ].each do |field|
      expect(page).to have_css(field[:sel], visible: visible, text: field[:text])
    end

    if visible
      expect(page).to have_css('.settings.expanded')
    else
      expect(page).not_to have_css('.settings.expanded')
    end
  end

  it 'shows "New project" page', :js do
    visit new_project_path

    find('#import-project-tab').click

    expect(page).to have_link('GitHub')
    expect(page).to have_link('Bitbucket')
    expect(page).to have_link('GitLab.com')
    expect(page).to have_link('Google Code')
    expect(page).to have_button('Repo by URL')
    expect(page).to have_link('GitLab export')
  end

  describe 'manifest import option' do
    before do
      visit new_project_path

      find('#import-project-tab').click
    end

    context 'when using postgres', :postgresql do
      it { expect(page).to have_link('Manifest file') }
    end

    context 'when using mysql', :mysql do
      it { expect(page).not_to have_link('Manifest file') }
    end
  end

  it 'Additional settings can be toggled', :js do
    visit new_project_path
    find('.js-settings-toggle')
    has_additional_fields
    find_button('Hide avatar, license and features settings').click
    has_additional_fields(false)
  end

  context 'Visibility level selector', :js do
    Gitlab::VisibilityLevel.options.each do |key, level|
      it "sets selector to #{key}" do
        stub_application_setting(default_project_visibility: level)

        visit new_project_path
        page.within('#blank-project-pane') do
          expect(find_field("project_visibility_level_#{level}")).to be_checked
        end
      end

      it "saves visibility level #{level} on validation error" do
        visit new_project_path

        choose(s_(key))
        click_button('Create project')
        page.within('#blank-project-pane') do
          expect(find_field("project_visibility_level_#{level}")).to be_checked
        end
      end
    end
  end

  it 'will set the license field when we select a license from the list', :js do
    license = 'MIT License'
    visit new_project_path
    select_license(license)
    expect(find('[name="project_license"]', visible: false).value).to eq("mit")
  end

  context 'Feature settings', :js do
    context 'with private visibility' do
      before do
        visit new_project_path

        select_project_visibility('Private', Gitlab::VisibilityLevel::PRIVATE)

        page.all('.project-feature-controls').each do |el|
          el.find('.project-feature-toggle').click
        end
      end

      it 'maintains disabled state for feature select boxes when the feature is enabled' do
        page.all('.project-feature-controls').each do |el|
          expect(el.find('.project-repo-select')).to be_disabled
        end
      end

      it 'sets each feature value to INTERNAL when the feature is enabled' do
        page.all('.project-feature-controls').each do |el|
          expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::INTERNAL)
        end
      end

      it 'sets each feature select to "Only project members" when the feature is enabled' do
        page.all('.project-feature-controls').each do |el|
          expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Only Project Members')
        end
      end

      context 'with each feature enabled' do
        before do
          visit new_project_path

          select_project_visibility('Private', Gitlab::VisibilityLevel::PRIVATE)
          page.all('.project-feature-controls').each do |el|
            el.find('.project-feature-toggle').click
          end
        end

        it 'switching to internal' do
          choose("Internal")
          page.all('.project-feature-controls').each do |el|
            expect(el.find('.project-repo-select')).not_to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::INTERNAL)
            expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Only Project Members')
          end
        end

        it 'switching to public' do
          choose("Public")
          page.all('.project-feature-controls').each do |el|
            expect(el.find('.project-repo-select')).not_to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::PUBLIC)
            expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Everyone With Access')
          end
        end
      end
    end

    context 'with internal visibility' do
      before do
        visit new_project_path

        select_project_visibility('Internal', Gitlab::VisibilityLevel::INTERNAL)
      end

      it 'enables feature select boxes when the feature is also enabled' do
        page.all('.project-feature-controls').each do |el|
          el.find('.project-feature-toggle').click
          expect(el.find('.project-repo-select')).not_to be_disabled
        end
      end

      it 'defaults each feature select to "Only Project Members" when enabled' do
        page.all('.project-feature-controls').each do |el|
          el.find('.project-feature-toggle').click
          expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::INTERNAL)
          expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Only Project Members')
        end
      end

      context 'with each feature enabled' do
        before do
          visit new_project_path

          select_project_visibility('Internal', Gitlab::VisibilityLevel::INTERNAL)

          page.all('.project-feature-controls').each do |el|
            el.find('.project-feature-toggle').click
            expect(el.find('.project-repo-select')).not_to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::INTERNAL)
            expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Only Project Members')
          end
        end

        it 'switching to private' do
          select_project_visibility('Private', Gitlab::VisibilityLevel::PRIVATE)

          page.all('.project-feature-controls').each do |el|
            expect(el.find('.project-repo-select')).to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::INTERNAL)
            expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Only Project Members')
          end
        end

        it 'switching to public' do
          select_project_visibility('Public', Gitlab::VisibilityLevel::PUBLIC)

          page.all('.project-feature-controls').each do |el|
            expect(el.find('.project-repo-select')).not_to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::PUBLIC)
            expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Everyone With Access')
          end
        end
      end
    end

    context 'with public visibility' do
      before do
        visit new_project_path

        select_project_visibility('Public', Gitlab::VisibilityLevel::PUBLIC)
      end

      it 'enables feature select boxes when the feature is also enabled' do
        page.all('.project-feature-controls').each do |el|
          el.find('.project-feature-toggle').click
          expect(el.find('.project-repo-select')).not_to be_disabled
        end
      end

      it 'defaults each feature select to "Everyone with access" when enabled' do
        page.all('.project-feature-controls').each do |el|
          el.find('.project-feature-toggle').click
          expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::PUBLIC)
          expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Everyone With Access')
        end
      end

      context 'with each feature enabled' do
        before do
          visit new_project_path

          select_project_visibility('Public', Gitlab::VisibilityLevel::PUBLIC)

          page.all('.project-feature-controls').each do |el|
            el.find('.project-feature-toggle').click
            expect(el.find('.project-repo-select')).not_to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::PUBLIC)
            expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Everyone With Access')
          end
        end

        it 'switching to internal' do
          select_project_visibility('Internal', Gitlab::VisibilityLevel::INTERNAL)

          page.all('.project-feature-controls').each do |el|
            expect(el.find('.project-repo-select')).not_to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::INTERNAL)
            expect(el.find('.project-repo-select').find('option[selected]').text).to eq('Only Project Members')
          end
        end

        it 'switching to private' do
          select_project_visibility('Private', Gitlab::VisibilityLevel::PRIVATE)

          page.all('.project-feature-controls').each do |el|
            expect(el.find('.project-repo-select')).to be_disabled
            expect(el.find('.project-repo-select', visible: false).value.to_i).to eq(Gitlab::VisibilityLevel::INTERNAL)
            expect(el.find('.project-repo-select').find('option[selected]', visible: false).text).to eq('Only Project Members')
          end
        end
      end
    end
  end

  context 'Readme selector' do
    it 'shows the initialize with Readme checkbox on "Blank project" tab' do
      visit new_project_path

      expect(page).to have_css('input#project_initialize_with_readme')
      expect(page).to have_content('Initialize repository with a README')
    end

    it 'does not show the initialize with Readme checkbox on "Create from template" tab' do
      visit new_project_path
      find('#create-from-template-pane').click
      first('.choose-template').click

      page.within '.project-fields-form' do
        expect(page).not_to have_css('input#project_initialize_with_readme')
        expect(page).not_to have_content('Initialize repository with a README')
      end
    end

    it 'does not show the initialize with Readme checkbox on "Import project" tab' do
      visit new_project_path
      find('#import-project-tab').click
      first('.js-import-git-toggle-button').click

      page.within '.toggle-import-form' do
        expect(page).not_to have_css('input#project_initialize_with_readme')
        expect(page).not_to have_content('Initialize repository with a README')
      end
    end
  end

  context 'Namespace selector' do
    context 'with user namespace' do
      before do
        visit new_project_path
      end

      it 'selects the user namespace' do
        page.within('#blank-project-pane') do
          namespace = find('#project_namespace_id')

          expect(namespace.text).to eq user.username
        end
      end
    end

    context 'with group namespace' do
      let(:group) { create(:group, :private) }

      before do
        group.add_owner(user)
        visit new_project_path(namespace_id: group.id)
      end

      it 'selects the group namespace' do
        page.within('#blank-project-pane') do
          namespace = find('#project_namespace_id option[selected]')

          expect(namespace.text).to eq group.name
        end
      end
    end

    context 'with subgroup namespace' do
      let(:group) { create(:group) }
      let(:subgroup) { create(:group, parent: group) }

      before do
        group.add_maintainer(user)
        visit new_project_path(namespace_id: subgroup.id)
      end

      it 'selects the group namespace' do
        page.within('#blank-project-pane') do
          namespace = find('#project_namespace_id option[selected]')

          expect(namespace.text).to eq subgroup.full_path
        end
      end
    end

    context 'when changing namespaces dynamically', :js do
      let(:public_group) { create(:group, :public) }
      let(:internal_group) { create(:group, :internal) }
      let(:private_group) { create(:group, :private) }

      before do
        public_group.add_owner(user)
        internal_group.add_owner(user)
        private_group.add_owner(user)
        visit new_project_path(namespace_id: public_group.id)
      end

      it 'enables the correct visibility options' do
        select2(user.namespace_id, from: '#project_namespace_id')
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PRIVATE}")).not_to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::INTERNAL}")).not_to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PUBLIC}")).not_to be_disabled

        select2(public_group.id, from: '#project_namespace_id')
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PRIVATE}")).not_to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::INTERNAL}")).not_to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PUBLIC}")).not_to be_disabled

        select2(internal_group.id, from: '#project_namespace_id')
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PRIVATE}")).not_to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::INTERNAL}")).not_to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PUBLIC}")).to be_disabled

        select2(private_group.id, from: '#project_namespace_id')
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PRIVATE}")).not_to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::INTERNAL}")).to be_disabled
        expect(find("#project_visibility_level_#{Gitlab::VisibilityLevel::PUBLIC}")).to be_disabled
      end
    end
  end

  context 'Import project options', :js do
    before do
      visit new_project_path
      find('#import-project-tab').click
    end

    context 'from git repository url, "Repo by URL"' do
      before do
        first('.js-import-git-toggle-button').click
      end

      it 'does not autocomplete sensitive git repo URL' do
        autocomplete = find('#project_import_url')['autocomplete']

        expect(autocomplete).to eq('off')
      end

      it 'shows import instructions' do
        git_import_instructions = first('.js-toggle-content')

        expect(git_import_instructions).to be_visible
        expect(git_import_instructions).to have_content 'Git repository URL'
      end

      it 'keeps "Import project" tab open after form validation error' do
        collision_project = create(:project, name: 'test-name-collision', namespace: user.namespace)

        fill_in 'project_import_url', with: collision_project.http_url_to_repo
        fill_in 'project_name', with: collision_project.name

        click_on 'Create project'

        expect(page).to have_css('#import-project-pane.active')
        expect(page).not_to have_css('.toggle-import-form.hide')
      end
    end

    context 'from GitHub' do
      before do
        first('.js-import-github').click
      end

      it 'shows import instructions' do
        expect(page).to have_content('Import repositories from GitHub')
        expect(current_path).to eq new_import_github_path
      end
    end

    context 'from Google Code' do
      before do
        first('.import_google_code').click
      end

      it 'shows import instructions' do
        expect(page).to have_content('Import projects from Google Code')
        expect(current_path).to eq new_import_google_code_path
      end
    end

    context 'from manifest file', :postgresql do
      before do
        first('.import_manifest').click
      end

      it 'shows import instructions' do
        expect(page).to have_content('Manifest file import')
        expect(current_path).to eq new_import_manifest_path
      end
    end
  end
end
