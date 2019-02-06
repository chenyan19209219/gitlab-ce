import Vue from 'vue';
import { createStore } from './store';
import ErrorTrackingSettings from './components/error_tracking_settings.vue';

const store = createStore();

const getInitialProject = dataset => {
  const {
    projectName: name,
    projectSlug: slug,
    projectOrganizationName: organizationName,
    projectOrganizationSlug: organizationSlug,
  } = dataset;
  if (slug) {
    return {
      id: `${organizationSlug}${slug}`,
      name,
      slug,
      organizationName,
      organizationSlug,
    };
  }
  return null;
};

export default () => {
  const formContainerEl = document.getElementsByClassName('js-error-tracking-form')[0];
  const {
    dataset: { apiHost, enabled, token, listProjectsEndpoint },
  } = formContainerEl;
  const operationsSettingsEndpoint = formContainerEl.getAttribute('action');
  const initialProject = getInitialProject(formContainerEl.dataset);

  // Set up initial store state from DOM
  store.dispatch('setInitialState', {
    apiHost,
    enabled: enabled === 'false' ? false : Boolean(enabled),
    token,
    project: initialProject,
  });

  return new Vue({
    el: formContainerEl,
    store,
    components: {
      ErrorTrackingSettings,
    },
    render(createElement) {
      return createElement(ErrorTrackingSettings, {
        props: {
          listProjectsEndpoint,
          operationsSettingsEndpoint,
        },
      });
    },
  });
};
