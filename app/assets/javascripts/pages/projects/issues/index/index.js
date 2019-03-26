/* eslint-disable no-new */

import IssuableIndex from '~/issuable_index';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import UsersSelect from '~/users_select';
import { ISSUABLE_INDEX } from '~/pages/projects/constants';
import initIssuesList from '~/issues';

document.addEventListener('DOMContentLoaded', () => {
  new IssuableIndex(ISSUABLE_INDEX.ISSUE);
  new ShortcutsNavigation();
  new UsersSelect();

  initIssuesList();
});
