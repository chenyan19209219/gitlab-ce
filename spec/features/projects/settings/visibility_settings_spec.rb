require 'spec_helper'

describe 'Projects > Settings > Visibility settings', :js do
  let(:user) { create(:user) }
  let(:project) { create(:project, namespace: user.namespace, visibility_level: 20) }

  context 'as owner' do
    before do
      sign_in(user)
      visit edit_project_path(project)
    end

    it 'project visibility select is available' do
      visibility_select_container = find('.project-visibility-setting')

      expect(visibility_select_container.find('select').value).to eq project.visibility_level.to_s
      expect(visibility_select_container).to have_content 'The project can be accessed by anyone, regardless of authentication.'
    end

    it 'project visibility description updates on change' do
      visibility_select_container = find('.project-visibility-setting')
      visibility_select = visibility_select_container.find('select')
      visibility_select.select('Private')

      expect(visibility_select.value).to eq '0'
      expect(visibility_select_container).to have_content 'Access must be granted explicitly to each user.'
    end

    context 'merge requests select' do
      it 'hides merge requests section' do
        find('.project-feature-controls[data-for="project[project_feature_attributes][merge_requests_access_level]"] .project-feature-toggle').click

        expect(page).to have_selector('.merge-requests-feature', visible: false)
      end

      context 'given project with merge_requests_disabled access level' do
        let(:project) { create(:project, :merge_requests_disabled, namespace: user.namespace) }

        it 'hides merge requests section' do
          expect(page).to have_selector('.merge-requests-feature', visible: false)
        end
      end
    end

    context 'builds select' do
      it 'hides builds select section' do
        find('.project-feature-controls[data-for="project[project_feature_attributes][builds_access_level]"] .project-feature-toggle').click

        expect(page).to have_selector('.builds-feature', visible: false)
      end

      context 'given project with builds_disabled access level' do
        let(:project) { create(:project, :builds_disabled, namespace: user.namespace) }

        it 'hides builds select section' do
          expect(page).to have_selector('.builds-feature', visible: false)
        end
      end
    end

    context 'fork level access' do
      context 'when the feature flag is enabled' do
        before do
          stub_feature_flags(show_forking_access_level: true)
        end

        enabled = %w[Private Internal]

        enabled.each do |item|
          it "shows the 'forks' settings panel for '#{item}' projects" do
            visit edit_project_path(project)
            select_project_visibility("#{item}")

            expect(page).to have_selector('.project-feature-controls[data-for="project[project_setting][forking_access_level]"]', visible: true)
          end
        end

        it 'does not show the "forks" settings panel for "Public" projects' do
          visit edit_project_path(project)
          select_project_visibility('Public')

          expect(page).not_to have_selector('.project-feature-controls[data-for="project[project_setting][forking_access_level]"]')
        end
      end

      context 'when the feature flag is disabled' do
        before do
          stub_feature_flags(show_forking_access_level: false)
        end

        disabled = %w[Public Private Internal]

        disabled.each do |item|
          it "does not show the 'forks' settings panel for '#{item}' projects" do
            visit edit_project_path(project)
            select_project_visibility("#{item}")

            expect(page).not_to have_selector('.project-feature-controls[data-for="project[project_setting][forking_access_level]"]')
          end
        end
      end
    end
  end

  context 'as maintainer' do
    let(:maintainer_user) { create(:user) }

    before do
      project.add_maintainer(maintainer_user)
      sign_in(maintainer_user)
      visit edit_project_path(project)
    end

    it 'project visibility is locked' do
      visibility_select_container = find('.project-visibility-setting')

      expect(visibility_select_container).to have_selector 'select[name="project[visibility_level]"]:disabled'
      expect(visibility_select_container).to have_content 'The project can be accessed by anyone, regardless of authentication.'
    end
  end

  def select_project_visibility(visibility)
    visibility_select_container = find('.project-visibility-setting')
    visibility_select = visibility_select_container.find('select')
    visibility_select.select(visibility)
  end
end
