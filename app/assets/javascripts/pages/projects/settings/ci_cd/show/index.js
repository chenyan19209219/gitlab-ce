import initSettingsPanels from '~/settings_panels';
import SecretValues from '~/behaviors/secret_values';
import initVariableList from '~/ci_variable_list_vue';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize expandable settings panels
  initSettingsPanels();

  const runnerToken = document.querySelector('.js-secret-runner-token');
  if (runnerToken) {
    const runnerTokenSecretValue = new SecretValues({
      container: runnerToken,
    });
    runnerTokenSecretValue.init();
  }

  initVariableList();

  // hide extra auto devops settings based checkbox state
  const autoDevOpsExtraSettings = document.querySelector('.js-extra-settings');
  const instanceDefaultBadge = document.querySelector('.js-instance-default-badge');
  document.querySelector('.js-toggle-extra-settings').addEventListener('click', event => {
    const { target } = event;
    if (instanceDefaultBadge) instanceDefaultBadge.style.display = 'none';
    autoDevOpsExtraSettings.classList.toggle('hidden', !target.checked);
  });
});
