import { shallowMount, createLocalVue } from '@vue/test-utils';
import DiffDiscussions from '~/diffs/components/diff_discussions.vue';
import NoteableDiscussion from '~/notes/components/noteable_discussion.vue';
import Icon from '~/vue_shared/components/icon.vue';
import { createStore } from '~/mr_notes/stores';
import '~/behaviors/markdown/render_gfm';
import discussionsMockData from '../mock_data/diff_discussions';

describe('DiffDiscussions', () => {
  let store;
  let wrapper;
  const getDiscussionsMockData = () => [Object.assign({}, discussionsMockData)];

  const createComponent = props => {
    const localVue = createLocalVue();
    store = createStore();
    wrapper = shallowMount(localVue.extend(DiffDiscussions), {
      store,
      propsData: {
        discussions: getDiscussionsMockData(),
        ...props,
      },
      localVue,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('template', () => {
    it('should have notes list', () => {
      createComponent();

      expect(wrapper.find(NoteableDiscussion).exists()).toBe(true);
    });
  });

  describe('image commenting', () => {
    it('renders collapsible discussion button', () => {
      createComponent({ shouldCollapseDiscussions: true });

      expect(wrapper.find('.js-diff-notes-toggle').exists()).toBe(true);

      expect(
        wrapper
          .find('.js-diff-notes-toggle')
          .find(Icon)
          .exists(),
      ).toBe(true);

      expect(wrapper.find('.js-diff-notes-toggle').classes('diff-notes-collapse')).toBe(true);
    });

    it('dispatches toggleDiscussion when clicking collapse button', () => {
      createComponent({ shouldCollapseDiscussions: true });
      spyOn(wrapper.vm.$store, 'dispatch').and.stub();

      wrapper.find('.js-diff-notes-toggle').trigger('click');

      expect(wrapper.vm.$store.dispatch).toHaveBeenCalledWith('toggleDiscussion', {
        discussionId: wrapper.vm.discussions[0].id,
      });
    });

    it('renders expand button when discussion is collapsed', () => {
      const discussions = getDiscussionsMockData();
      discussions[0].expanded = false;
      createComponent({ discussions, shouldCollapseDiscussions: true });

      expect(
        wrapper
          .find('.js-diff-notes-toggle')
          .text()
          .trim(),
      ).toBe('1');

      ['btn-transparent', 'badge', 'badge-pill'].forEach(c => {
        expect(wrapper.find('.js-diff-notes-toggle').classes(c)).toBe(true);
      });
    });

    it('hides discussion when collapsed', () => {
      const discussions = getDiscussionsMockData();
      discussions[0].expanded = false;
      createComponent({ discussions, shouldCollapseDiscussions: true });

      expect(wrapper.find(NoteableDiscussion).isVisible()).toBe(false);
    });

    it('renders badge on avatar', () => {
      createComponent({ renderAvatarBadge: true });

      expect(
        wrapper
          .find(NoteableDiscussion)
          .find('.badge-pill')
          .exists(),
      ).toBe(true);

      expect(
        wrapper
          .find(NoteableDiscussion)
          .find('.badge-pill')
          .text()
          .trim(),
      ).toBe('1');
    });
  });
});
