import * as types from './mutation_types';

const sortVariables = variables => variables.sort((a, b) => a.id - b.id);

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    Object.assign(state, {
      endpoint,
    });
  },
  [types.REQUEST_VARIABLES](state) {
    Object.assign(state, {
      isLoading: true,
    });
  },
  [types.RECEIVE_VARIABLES_SUCCESS](state, data) {
    Object.assign(state, {
      isLoading: false,
      variables: sortVariables(data.variables),
    });
  },
  [types.RECEIVE_VARIABLES_ERROR](state, error) {
    Object.assign(state, {
      isLoading: false,
      error,
    });
  },
  [types.TOGGLE_VALUES_VISIBILITY](state) {
    Object.assign(state, {
      valuesVisible: !state.valuesVisible,
    });
  },
  [types.SET_MODAL_VARIABLE](state, variable) {
    Object.assign(state, {
      modalVariableKey: variable.key,
      modalVariable: variable,
    });
  },
  [types.UPDATE_MODAL_VARIABLE](state, variable) {
    Object.assign(state, {
      modalVariable: variable,
    });
  },
  [types.REQUEST_DELETE_VARIABLE](state, variable) {
    Object.assign(state, {
      isDeletingVariable: variable,
    });
  },
  [types.RECEIVE_DELETE_VARIABLE_SUCCESS](state, data) {
    Object.assign(state, {
      isDeletingVariable: false,
      variables: sortVariables(data.variables),
    });
  },
  [types.RECEIVE_DELETE_VARIABLE_ERROR](state, error) {
    Object.assign(state, {
      isDeletingVariable: false,
      error,
    });
  },
  [types.REQUEST_ADD_VARIABLE](state, variable) {
    Object.assign(state, {
      isAddingVariable: variable,
    });
  },
  [types.RECEIVE_ADD_VARIABLE_SUCCESS](state, data) {
    Object.assign(state, {
      isAddingVariable: false,
      variables: sortVariables(data.variables),
    });
  },
  [types.RECEIVE_ADD_VARIABLE_ERROR](state, error) {
    Object.assign(state, {
      isAddingVariable: false,
      error,
    });
  },
  [types.REQUEST_UPDATE_VARIABLE](state, variable) {
    Object.assign(state, {
      isUpdatingVariable: variable,
    });
  },
  [types.RECEIVE_UPDATE_VARIABLE_SUCCESS](state, data) {
    Object.assign(state, {
      isUpdatingVariable: false,
      variables: sortVariables(data.variables),
    });
  },
  [types.RECEIVE_UPDATE_VARIABLE_ERROR](state, error) {
    Object.assign(state, {
      isUpdatingVariable: false,
      error,
    });
  },
};
