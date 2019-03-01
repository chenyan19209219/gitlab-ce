import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);
export const toggleValuesVisibility = ({ commit }) => commit(types.TOGGLE_VALUES_VISIBILITY);
export const setModalVariable = ({ commit }, variable) =>
  commit(types.SET_MODAL_VARIABLE, variable);
export const updateModalVariable = ({ commit }, variable) =>
  commit(types.UPDATE_MODAL_VARIABLE, variable);

export const requestVariables = ({ commit }) => commit(types.REQUEST_VARIABLES);
export const receiveVariablesSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_VARIABLES_SUCCESS, data);
export const receiveVariablesError = ({ commit }, error) =>
  commit(types.RECEIVE_VARIABLES_ERROR, error);

export const fetchVariables = ({ state, dispatch }) => {
  dispatch('requestVariables');
  axios
    .get(state.endpoint)
    .then(({ data }) => dispatch('receiveVariablesSuccess', data))
    .catch(error => {
      dispatch('receiveVariablesError', error);
      createFlash('There was an error');
    });
};

export const requestDeleteVariable = ({ commit }) => commit(types.REQUEST_DELETE_VARIABLE);
export const receiveDeleteVariableSuccess = ({ commit }, variable) =>
  commit(types.RECEIVE_DELETE_VARIABLE_SUCCESS, variable);
export const receiveDeleteVariableError = ({ commit }, error) =>
  commit(types.RECEIVE_DELETE_VARIABLE_ERROR, error);

export const deleteVariable = ({ state, dispatch }) => {
  const variableToDelete = Object.assign(state.modalVariable, { _destroy: true });
  dispatch('requestDeleteVariable');
  axios
    .patch(`${state.endpoint}`, { variables_attributes: [variableToDelete] })
    .then(({ data }) => dispatch('receiveDeleteVariableSuccess', data))
    .catch(error => {
      dispatch('receiveDeleteVariableError', error);
      createFlash('There was an error');
    });
};

export const requestAddVariable = ({ commit }) => commit(types.REQUEST_ADD_VARIABLE);
export const receiveAddVariableSuccess = ({ commit }, variable) =>
  commit(types.RECEIVE_ADD_VARIABLE_SUCCESS, variable);
export const receiveAddVariableError = ({ commit }, error) =>
  commit(types.RECEIVE_ADD_VARIABLE_ERROR, error);

export const addVariable = ({ state, dispatch }) => {
  const newVariable = state.modalVariable;
  newVariable.secret_value = newVariable.value;
  dispatch('requestAddVariable');
  axios
    .patch(state.endpoint, { variables_attributes: [newVariable] })
    .then(({ data }) => dispatch('receiveAddVariableSuccess', data))
    .catch(error => {
      dispatch('receiveAddVariableError', error);
      createFlash('There was an error');
    });
};

export const requestUpdateVariable = ({ commit }) => commit(types.REQUEST_UPDATE_VARIABLE);
export const receiveUpdateVariableSuccess = ({ commit }, variable) =>
  commit(types.RECEIVE_UPDATE_VARIABLE_SUCCESS, variable);
export const receiveUpdateVariableError = ({ commit }, error) =>
  commit(types.RECEIVE_UPDATE_VARIABLE_ERROR, error);

export const updateVariable = ({ state, dispatch }) => {
  const updatedVariable = state.modalVariable;
  updatedVariable.secret_value = updatedVariable.value;
  dispatch('requestUpdateVariable');
  axios
    .patch(`${state.endpoint}`, { variables_attributes: [updatedVariable] })
    .then(({ data }) => dispatch('receiveUpdateVariableSuccess', data))
    .catch(error => {
      dispatch('receiveUpdateVariableError', error);
      createFlash('There was an error');
    });
};
