import _ from 'underscore';
import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import ProjectDropdown from '~/error_tracking_settings/components/project_dropdown.vue';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';

const localVue = createLocalVue();
localVue.use(Vuex);

const testProjects = [
  {
    id: 1,
    name: 'name',
    slug: 'slug',
    organizationName: 'organizationName',
    organizationSlug: 'organizationSlug',
  },
  {
    id: 2,
    name: 'name2',
    slug: 'slug2',
    organizationName: 'organizationName2',
    organizationSlug: 'organizationSlug2',
  },
];

const staleProject = {
  id: 3,
  name: 'staleName',
  slug: 'staleSlug',
  organizationName: 'staleOrganizationName',
  organizationSlug: 'staleOrganizationSlug',
};

describe('ErrorTrackingSettings', () => {
  let store;
  let wrapper;

  function mountComponent() {
    wrapper = shallowMount(ProjectDropdown, {
      localVue,
      store,
    });
  }

  beforeEach(() => {
    const actions = {};

    const state = {
      token: '',
      projects: null,
      selectedProject: null,
    };

    store = new Vuex.Store({
      actions,
      state,
    });

    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('Empty project list', () => {
    it('Renders the dropdown', () => {
      expect(wrapper.find('#project_dropdown').exists()).toBeTruthy();
      expect(wrapper.find(GlDropdown).exists()).toBeTruthy();
    });

    it('shows helper text', () => {
      expect(wrapper.find('[data-qa-id=project_dropdown_label]').exists()).toBeTruthy();
      expect(wrapper.find('[data-qa-id="project_dropdown_label"]').text()).toContain(
        'To enable project selection',
      );
    });

    it('does not show an error', () => {
      expect(wrapper.find('[data-qa-id="project_dropdown_error"]').exists()).toBeFalsy();
    });

    it('does not contain any dropdown items', () => {
      expect(wrapper.find(GlDropdownItem).exists()).toBeFalsy();
      // expect(wrapper.find('#project_dropdown > button').text()).toBe('No projects available');
    });
  });

  describe('Populated project list', () => {
    beforeEach(() => {
      store.state.projects = _.clone(testProjects);
    });

    it('Renders the dropdown', () => {
      expect(wrapper.find('#project_dropdown').exists()).toBeTruthy();
      expect(wrapper.find(GlDropdown).exists()).toBeTruthy();
      expect(wrapper.find(GlDropdown).props('text')).toContain('Select project');
    });

    it('contains a number of dropdown items', () => {
      expect(wrapper.find(GlDropdownItem).exists()).toBeTruthy();
      expect(wrapper.findAll(GlDropdownItem).length).toBe(2);
    });
  });

  describe('Selected project', () => {
    const selectedProject = _.clone(testProjects[0]);

    beforeEach(() => {
      store.state.projects = _.clone(testProjects);
      store.state.selectedProject = selectedProject;
    });

    it('displays the selected project', () => {
      expect(wrapper.find('#project_dropdown').props('text')).toContain(
        selectedProject.organizationName,
      );

      expect(wrapper.find('#project_dropdown').props('text')).toContain(selectedProject.name);
    });

    it('does not show helper text', () => {
      expect(wrapper.find('[data-qa-id=project_dropdown_label]').exists()).toBeFalsy();
      expect(wrapper.find('[data-qa-id=project_dropdown_error]').exists()).toBeFalsy();
    });
  });

  describe('Invalid project selected', () => {
    beforeEach(() => {
      store.state.projects = _.clone(testProjects);
      store.state.selectedProject = staleProject;
    });

    it('displays the selected project', () => {
      expect(wrapper.find('#project_dropdown').props('text')).toContain(
        staleProject.organizationName,
      );

      expect(wrapper.find('#project_dropdown').props('text')).toContain(staleProject.name);
    });

    it('displays a error', () => {
      expect(wrapper.find('[data-qa-id=project_dropdown_label]').exists()).toBeFalsy();
      expect(wrapper.find('[data-qa-id=project_dropdown_error]').exists()).toBeTruthy();
    });
  });
});
