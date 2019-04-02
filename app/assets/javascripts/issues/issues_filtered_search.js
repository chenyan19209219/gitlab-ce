import IssuableFilteredSearchTokenKeys from 'ee_else_ce/filtered_search/issuable_filtered_search_token_keys';
import { FILTERED_SEARCH } from '~/pages/constants';
import FilteredSearchManager from '~/filtered_search/filtered_search_manager';
import { historyPushState } from '~/lib/utils/common_utils';
import issuesListStore from './stores';

IssuableFilteredSearchTokenKeys.addExtraTokensForIssues();

export default class FilteredSearchIssueAnalytics extends FilteredSearchManager {
  constructor() {
    super({
      page: FILTERED_SEARCH.ISSUES,
      isGroup: true,
      isGroupDecendent: true,
      filteredSearchTokenKeys: IssuableFilteredSearchTokenKeys,
    });

    this.isHandledAsync = true;
  }

  updateObject = path => {
    historyPushState(path);

    issuesListStore.dispatch('issuesList/setFilters', path);
    issuesListStore.dispatch('issuesList/setCurrentPage', 1);
  };
}
