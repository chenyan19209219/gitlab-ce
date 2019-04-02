/* eslint-disable no-new */

import IssuableIndex from '~/issuable_index';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import UsersSelect from '~/users_select';
import initIssuesList from '~/issues';
import initFilteredSearch from '~/pages/search/init_filtered_search';
import IssuableFilteredSearchTokenKeys from 'ee_else_ce/filtered_search/issuable_filtered_search_token_keys';
import { ISSUABLE_INDEX } from '~/pages/projects/constants';
import { FILTERED_SEARCH } from '~/pages/constants';

document.addEventListener('DOMContentLoaded', () => {
  if (gon.features.issuesVueComponent) {
    initIssuesList();
  } else {
    IssuableFilteredSearchTokenKeys.addExtraTokensForIssues();

    initFilteredSearch({
      page: FILTERED_SEARCH.ISSUES,
      filteredSearchTokenKeys: IssuableFilteredSearchTokenKeys,
    });

    new IssuableIndex(ISSUABLE_INDEX.ISSUE);
  }

  new ShortcutsNavigation();
  new UsersSelect();
});
