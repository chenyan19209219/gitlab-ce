// TODO: https://gitlab.com/gitlab-org/gitlab-ce/issues/48034

import Vue from 'vue';
import CompareVersionsDropdown from '~/diffs/components/compare_versions_dropdown.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import diffsMockData from '../mock_data/merge_request_diffs';

describe('CompareVersionsDropdown', () => {
  let vm;
  const Component = Vue.extend(CompareVersionsDropdown);
  const targetBranch = { branchName: 'tmp-wine-dev', versionIndex: -1 };

  beforeEach(() => {
    vm = mountComponent(Component, { otherVersions: diffsMockData.slice(1), targetBranch });
  });

  it('should render a correct base version link', () => {
    const links = vm.$el.querySelectorAll('a');
    const lastLink = links[links.length - 1];

    expect(lastLink).toHaveAttr('href', '/gnuwget/wget2/merge_requests/6/diffs?diff_id=37');
  });
});
