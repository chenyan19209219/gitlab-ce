import initSettingsPanels from '~/settings_panels';
import initVariableList from '~/ci_variable_list_vue';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize expandable settings panels
  initSettingsPanels();

  initVariableList();
});
