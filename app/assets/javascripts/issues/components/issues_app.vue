<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import IssuableIndex from '~/issuable_index';
import { ISSUABLE_INDEX } from '~/pages/projects/constants';
import { getParameterValues } from '~/lib/utils/url_utility';
import Issue from './issue.vue';
import IssuesEmptyState from './empty_state.vue';

const issuableIndex = new IssuableIndex(ISSUABLE_INDEX.ISSUE);

export default {
  components: {
    IssuesEmptyState,
    Issue,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    canBulkUpdate: {
      type: Boolean,
      required: true,
    },
    createPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState('issuesList', ['issues', 'loading', 'isBulkUpdating']),
    ...mapGetters('issuesList', ['hasFilters', 'appliedFilters']),

    currentState() {
      const [state] = getParameterValues('state');
      return state || 'opened';
    },
  },
  watch: {
    appliedFilters() {
      this.fetchIssues(this.endpoint);
      this.updateIssueStateTabs();
    },
    issues() {
      this.setupExternalEvents();
    },
  },
  mounted() {
    this.fetchIssues(this.endpoint);
    this.updateIssueStateTabs();
    this.setupExternalEvents();
  },
  updated() {
    this.setupExternalEvents();
  },
  methods: {
    ...mapActions('issuesList', ['fetchIssues']),
    updateIssueStateTabs() {
      const activeTabEl = document.querySelector('.issues-state-filters .active');
      const newActiveTabEl = document.querySelector(
        `.issues-state-filters [data-state="${this.currentState}"]`,
      );

      if (activeTabEl && !activeTabEl.querySelector(`[data-state="${this.currentState}"]`)) {
        activeTabEl.classList.remove('active');
        newActiveTabEl.parentElement.classList.add('active');
      } else {
        newActiveTabEl.parentElement.classList.add('active');
      }
    },
    setupExternalEvents() {
      issuableIndex.bulkUpdateSidebar.initDomElements();
      issuableIndex.bulkUpdateSidebar.bindEvents();
    },
  },
};
</script>
<template>
  <ul v-if="issues && issues.length > 0" class="content-list issues-list issuable-list">
    <issue
      v-for="issue in issues"
      :key="issue.id"
      :issue="issue"
      :is-bulk-updating="isBulkUpdating"
      :can-bulk-update="canBulkUpdate"
    />
  </ul>
  <issues-empty-state
    v-else
    :has-filters="hasFilters"
    :state="currentState"
    :button-path="createPath"
  />
</template>
