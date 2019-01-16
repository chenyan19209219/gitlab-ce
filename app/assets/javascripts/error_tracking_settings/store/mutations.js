import * as types from './mutation_types';

export default {
  [types.RECEIVE_PROJECTS](state, projects) {
    state.projects = projects;
  },
  [types.UPDATE_API_HOST](state, apiHost) {
    state.apiHost = apiHost;
  },
  [types.UPDATE_ENABLED](state, enabled) {
    state.enabled = enabled;
  },
  [types.UPDATE_TOKEN](state, token) {
    state.token = token;
  },
  [types.UPDATE_SELECTED_PROJECT](state, selectedProject) {
    state.selectedProject = selectedProject;
  },
  [types.UPDATE_CONNECT_SUCCESS](state) {
    state.connectSuccessful = true;
    state.connectError = false;
  },
  [types.UPDATE_CONNECT_ERROR](state) {
    state.connectSuccessful = false;
    state.connectError = true;
  },
  [types.RESET_CONNECT](state) {
    state.connectSuccessful = false;
    state.connectError = false;
  },
  [types.UPDATE_SETTINGS_LOADING](state, settingsLoading) {
    state.settingsLoading = settingsLoading;
  },
};
