/* eslint-disable no-new */

import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import UsersSelect from '~/users_select';
import initIssuesList from '~/issues';

document.addEventListener('DOMContentLoaded', () => {
  new ShortcutsNavigation();
  new UsersSelect();

  initIssuesList();
});
