import Vue from 'vue';
import { ISSUABLE_INDEX } from '~/pages/projects/constants';
import IssuableIndex from '~/issuable_index';
import store from './stores';
import IssuesApp from './components/issues_app.vue';
import IssuesFilteredSearch from './issues_filtered_search';

export default () => {
  const el = document.querySelector('#js-issues-list');

  if (!el) return null;

  const { endpoint, canUpdate } = el.dataset;
  const canBulkUpdate = canUpdate === 'true';
  const issuableIndex = new IssuableIndex(ISSUABLE_INDEX.ISSUE, store);

  // Set default filters from URL
  store.dispatch('issuesList/setFilters', window.location.search);

  return new Vue({
    el,
    store,
    components: {
      IssuesApp,
    },
    mounted() {
      this.filteredSearch = new IssuesFilteredSearch(store.state.issuesList.filters);
      this.filteredSearch.setup();

      issuableIndex.bulkUpdateSidebar.initDomElements();
      issuableIndex.bulkUpdateSidebar.bindEvents();
    },
    updated() {
      issuableIndex.bulkUpdateSidebar.initDomElements();
      issuableIndex.bulkUpdateSidebar.bindEvents();
    },
    render(createElement) {
      return createElement('issues-app', {
        props: {
          endpoint,
          canBulkUpdate,
        },
      });
    },
  });
};
