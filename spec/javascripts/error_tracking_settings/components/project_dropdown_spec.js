import _ from 'underscore';
import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import ProjectDropdown from '~/error_tracking_settings/components/project_dropdown.vue';
import { createStore } from '~/error_tracking_settings/store';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { projectList, staleProject } from '../mock';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('error tracking settings project dropdown', () => {
  let store;
  let wrapper;

  function mountComponent() {
    wrapper = shallowMount(ProjectDropdown, {
      localVue,
      store,
    });
  }

  beforeEach(() => {
    store = createStore();

    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('empty project list', () => {
    it('renders the dropdown', () => {
      expect(wrapper.find('#project-dropdown').exists()).toBeTruthy();
      expect(wrapper.find(GlDropdown).exists()).toBeTruthy();
    });

    it('shows helper text', () => {
      expect(wrapper.find('[data-qa-id=project-dropdown-label]').exists()).toBeTruthy();
      expect(wrapper.find('[data-qa-id="project-dropdown-label"]').text()).toContain(
        'To enable project selection',
      );
    });

    it('does not show an error', () => {
      expect(wrapper.find('[data-qa-id="project-dropdown-error"]').exists()).toBeFalsy();
    });

    it('does not contain any dropdown items', () => {
      expect(wrapper.find(GlDropdownItem).exists()).toBeFalsy();
      expect(wrapper.find(GlDropdown).props('text')).toBe('No projects available');
    });
  });

  describe('populated project list', () => {
    beforeEach(() => {
      store.state.projects = _.clone(projectList);
    });

    it('renders the dropdown', () => {
      expect(wrapper.find('#project-dropdown').exists()).toBeTruthy();
      expect(wrapper.find(GlDropdown).exists()).toBeTruthy();
      expect(wrapper.find(GlDropdown).props('text')).toContain('Select project');
    });

    it('contains a number of dropdown items', () => {
      expect(wrapper.find(GlDropdownItem).exists()).toBeTruthy();
      expect(wrapper.findAll(GlDropdownItem).length).toBe(2);
    });
  });

  describe('selected project', () => {
    const selectedProject = _.clone(projectList[0]);

    beforeEach(() => {
      store.state.projects = _.clone(projectList);
      store.state.selectedProject = selectedProject;
    });

    it('displays the selected project', () => {
      expect(wrapper.find(GlDropdown).props('text')).toContain(selectedProject.organizationName);

      expect(wrapper.find(GlDropdown).props('text')).toContain(selectedProject.name);
    });

    it('does not show helper text', () => {
      expect(wrapper.find('[data-qa-id=project-dropdown-label]').exists()).toBeFalsy();
      expect(wrapper.find('[data-qa-id=project-dropdown-error]').exists()).toBeFalsy();
    });
  });

  describe('invalid project selected', () => {
    beforeEach(() => {
      store.state.projects = _.clone(projectList);
      store.state.selectedProject = staleProject;
    });

    it('displays the selected project', () => {
      expect(wrapper.find(GlDropdown).props('text')).toContain(staleProject.organizationName);

      expect(wrapper.find(GlDropdown).props('text')).toContain(staleProject.name);
    });

    it('displays a error', () => {
      expect(wrapper.find('[data-qa-id=project-dropdown-label]').exists()).toBeFalsy();
      expect(wrapper.find('[data-qa-id=project-dropdown-error]').exists()).toBeTruthy();
    });
  });
});
