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

  // TODO: Possible BE changes needed for missing fields:
  // - Populate namespace with correct data:
  //  * no group set => should default to the user's name
  //  * subgroups??
  //  * pipeline-status
  //  * last_activity_at (api) != last_activity_date (haml)
  //  * open_merge_requests_count
  //  * open_issues_count
  //  * project visibility
  // - description field: should show the last commit as a description if available otherwise just the project description

  // TODO: additional cases
  // - project.archived?

  describe('data', () => {
    it('returns default data props', () => {
      const projectFields = [
        'id',
        'name',
        'description',
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
    describe('Project meta', () => {
      it('renders the correct project name', () => {
        expect(vm.$el.querySelector('.project-name').innerText).toBe(selectedProject.name);
      });

      it('renders the project avatar as a link', () => {
        expect(vm.$el.querySelector('.avatar-container a').href).toContain(selectedProject.path);
      });

      it('renders the correct project description', () => {
        expect(vm.$el.querySelector('.description').innerText).toBe(selectedProject.description);
      });

      it('does not render the description if it is missing', () => {
        ['', null].forEach(description => {
          const noDescVm = createComponent({ ...selectedProject, description });

          expect(noDescVm.$el.querySelector('.description')).toBeNull();
        });
      });

      it('renders the project namespace name if it is available', () => {
        expect(vm.$el.querySelector('.namespace-name').innerText).toEqual(
          `${selectedProject.namespace.name} /`,
        );
      });
    });

    describe('Icons', () => {
      const path = selectedProject.path_with_namespace;
      const urls = {
        forks: `/${path}/forks`,
        issues: `/${path}/issues`,
        'merge-requests': `/${path}/merge_requests`,
      };

      it('renders the correct urls for forks, issues and merge requests', () => {
        Object.entries(urls).forEach(([key, url]) => {
          expect(vm.$el.querySelector(`.icon-container .${key}`).href).toContain(url);
        });
      });

      it('renders the correct star count', () => {
        const stars = Number(vm.$el.querySelector('.stars').textContent);

        expect(stars).toEqual(selectedProject.star_count);
      });

      it('renders the correct fork count', () => {
        const forks = Number(vm.$el.querySelector('.forks').textContent);

        expect(forks).toEqual(selectedProject.forks_count);
      });

      it('renders the correct issue count', () => {
        const issues = Number(vm.$el.querySelector('.issues').textContent);

        expect(issues).toEqual(selectedProject.open_issues_count);
      });

      it('renders the correct merge request count', () => {
        const mergeRequests = Number(vm.$el.querySelector('.merge-requests').textContent);

        expect(mergeRequests).toEqual(selectedProject.merge_requests_count);
      });
    });
  });
});
