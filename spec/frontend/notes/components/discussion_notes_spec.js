import DiscussionNotes from '~/notes/components/discussion_notes.vue';
import createStore from '~/notes/stores';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import {
  noteableDataMock,
  discussionMock,
  notesDataMock,
} from '../../../javascripts/notes/mock_data';
import '~/behaviors/markdown/render_gfm';

const factory = ({ localVue, store }) =>
  shallowMount(DiscussionNotes, {
    localVue,
    store,
    propsData: {
      canReply: false,
      discussion: discussionMock,
      firstNote: discussionMock.notes.slice(0, 1)[0],
      hasReplies: false,
      isExpanded: false,
      shouldGroupReplies: false,
    },
  });

describe('DiscussionNotes', () => {
  let wrapper;

  beforeEach(() => {
    const localVue = createLocalVue();
    const store = createStore();
    store.dispatch('setNoteableData', noteableDataMock);
    store.dispatch('setNotesData', notesDataMock);

    wrapper = factory({ localVue, store });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders an element for each note in the discussion', () => {
    const notesCount = discussionMock.notes.length;
    const els = wrapper.findAll('.notes > li');
    expect(els.length).toBe(notesCount);
  });

  it('renders one element if replies groupping is enabled', () => {
    wrapper.setProps({
      shouldGroupReplies: true,
    });
    const els = wrapper.findAll('.notes > li');
    expect(els.length).toBe(1);
  });

  describe('componentData', () => {
    it('should return first note object for placeholder note', () => {
      const data = {
        isPlaceholderNote: true,
        notes: [{ body: 'hello world!' }],
      };
      const note = wrapper.vm.componentData(data);

      expect(note).toEqual(data.notes[0]);
    });

    it('should return given note for nonplaceholder notes', () => {
      const data = {
        notes: [{ id: 12 }],
      };
      const note = wrapper.vm.componentData(data);

      expect(note).toEqual(data);
    });
  });
});
