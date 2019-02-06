import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';
import { transformBackendProject, transformFrontendSettings } from './utils';
import createFlash from '~/flash';
import { __ } from '~/locale';

export const requestProjects = ({ commit }) => {
  commit(types.RESET_CONNECT);
};

export const receiveProjectsSuccess = ({ commit }, projects) => {
  commit(types.UPDATE_CONNECT_SUCCESS);
  commit(types.RECEIVE_PROJECTS, projects);
};

export const receiveProjectsError = ({ commit }) => {
  commit(types.UPDATE_CONNECT_ERROR);
  commit(types.RECEIVE_PROJECTS, null);
};

export const fetchProjects = ({ dispatch, state }, data) => {
  dispatch('requestProjects');
  return axios
    .post(`${data.listProjectsEndpoint}.json`, {
      error_tracking_setting: {
        api_host: state.apiHost,
        token: state.token,
      },
    })
    .then(res => {
      dispatch('receiveProjectsSuccess', res.data.projects.map(transformBackendProject));
    })
    .catch(() => {
      dispatch('receiveProjectsError');
    });
};

export const requestSettings = ({ commit }) => {
  commit(types.UPDATE_SETTINGS_LOADING, true);
};

export const receiveSettingsSuccess = ({ commit }) => {
  createFlash(__('Your changes have been saved.'), 'notice');
  commit(types.UPDATE_SETTINGS_LOADING, false);
};

export const receiveSettingsError = ({ commit }, response) => {
  const data = response.data || {};
  const message = data.message || '';

  createFlash(`${__('There was an error saving your changes.')} ${message}`, 'alert');
  commit(types.UPDATE_SETTINGS_LOADING, false);
};

export const updateSettings = ({ dispatch, state }, data) => {
  dispatch('requestSettings');
  return axios
    .patch(data.operationsSettingsEndpoint, {
      project: {
        error_tracking_setting_attributes: {
          ...transformFrontendSettings(state),
        },
      },
    })
    .then(() => {
      dispatch('receiveSettingsSuccess');
    })
    .catch(err => {
      dispatch('receiveSettingsError', err.response);
    });
};

export const updateApiHost = ({ commit }, apiHost) => {
  commit(types.UPDATE_API_HOST, apiHost);
  commit(types.RESET_CONNECT);
};

export const updateEnabled = ({ commit }, enabled) => {
  commit(types.UPDATE_ENABLED, enabled);
};

export const updateToken = ({ commit }, token) => {
  commit(types.UPDATE_TOKEN, token);
  commit(types.RESET_CONNECT);
};

export const updateSelectedProject = ({ commit }, selectedProject) => {
  commit(types.UPDATE_SELECTED_PROJECT, selectedProject);
};

export const setInitialState = ({ dispatch }, { apiHost, enabled, token, project }) => {
  dispatch('updateApiHost', apiHost);
  dispatch('updateEnabled', enabled === 'false' ? false : Boolean(enabled));
  dispatch('updateToken', token);
  dispatch('updateSelectedProject', project);
};

export default () => {};
