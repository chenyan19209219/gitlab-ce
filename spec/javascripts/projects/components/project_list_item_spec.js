import Vue from 'vue';

import ProjectListItem from '~/projects/components/project_list_item.vue';

import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { data } from './mockData.json';
// TODO: this should be fixture
const selectedProject = data[0];

const createComponent = project => {
  const Component = Vue.extend(ProjectListItem);

  return mountComponent(Component, {
    project,
  });
};

describe('ProjectListItem', () => {
  let vm;

  beforeEach(() => {
    vm = createComponent(selectedProject);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('data', () => {
    it('returns default data props', () => {
      const projectFields = [
        'id',
        'name',
        'path',
        'path_with_namespace',
        'created_at',
        'tag_list',
        'ssh_url_to_repo',
        'http_url_to_repo',
        'web_url',
        'star_count',
        'forks_count',
        'last_activity_at',
      ];
      projectFields.forEach(field => {
        expect(vm.project[field]).toBe(selectedProject[field]);
      });

      const namespaceFields = ['id', 'name', 'path', 'kind', 'full_path', 'parent_id'];
      namespaceFields.forEach(field => {
        expect(vm.project.namespace[field]).toBe(selectedProject.namespace[field]);
      });
    });
  });

  describe('template', () => {
    it('renders the correct project name', () => {
      expect(vm.$el.querySelector('.project-name').innerText).toBe(selectedProject.name);
    });

    it('renders the project namespace name if it is available', () => {
      const ns = `${selectedProject.namespace.name} /`;

      expect(vm.$el.querySelector('.namespace-name').innerText).toBe(ns);
    });
  });
});
