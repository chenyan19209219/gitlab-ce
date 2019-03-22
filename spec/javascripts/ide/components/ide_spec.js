import Vue from 'vue';
import store from '~/ide/stores';
import ide from '~/ide/components/ide.vue';
import { createComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import { file, resetStore } from '../helpers';
import { projectData } from '../mock_data';

describe('ide component', () => {
  let vm;

  beforeEach(() => {
    const Component = Vue.extend(ide);

    store.state.currentProjectId = 'abcproject';
    store.state.currentBranchId = 'master';
    store.state.projects.abcproject = Object.assign({}, projectData);
    Vue.set(store.state.trees, 'abcproject/master', {
      tree: [],
      loading: false,
    });

    vm = createComponentWithStore(Component, store, {
      emptyStateSvgPath: 'svg',
      noChangesStateSvgPath: 'svg',
      committedStateSvgPath: 'svg',
    }).$mount();
  });

  afterEach(() => {
    vm.$destroy();

    resetStore(vm.$store);
  });

  it('shows error message when set', done => {
    expect(vm.$el.querySelector('.flash-container')).toBe(null);

    vm.$store.state.errorMessage = {
      text: 'error',
    };

    vm.$nextTick(() => {
      expect(vm.$el.querySelector('.flash-container')).not.toBe(null);

      done();
    });
  });

  describe('onBeforeUnload', () => {
    it('returns undefined when no staged files or changed files', () => {
      expect(vm.onBeforeUnload()).toBe(undefined);
    });

    it('returns warning text when their are changed files', () => {
      vm.$store.state.changedFiles.push(file());

      expect(vm.onBeforeUnload()).toBe('Are you sure you want to lose unsaved changes?');
    });

    it('returns warning text when their are staged files', () => {
      vm.$store.state.stagedFiles.push(file());

      expect(vm.onBeforeUnload()).toBe('Are you sure you want to lose unsaved changes?');
    });

    it('updates event object', () => {
      const event = {};
      vm.$store.state.stagedFiles.push(file());

      vm.onBeforeUnload(event);

      expect(event.returnValue).toBe('Are you sure you want to lose unsaved changes?');
    });
  });

  describe('empty/non-existent branch', () => {
    it('renders "New file" button', done => {
      vm.$nextTick(() => {
        expect(vm.$el.querySelector('.ide-empty-state button[title="New file"]')).not.toBeNull();
        done();
      });
    });
  });

  describe('branch with files', () => {
    beforeEach(() => {
      store.state.trees['abcproject/master'].tree = [file()];
    });

    it('does not render "New file" button', done => {
      vm.$nextTick(() => {
        expect(vm.$el.querySelector('.ide-empty-state button[title="New file"]')).toBeNull();
        done();
      });
    });
  });
});
