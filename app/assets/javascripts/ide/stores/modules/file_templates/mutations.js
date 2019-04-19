import * as types from './mutation_types';

export default {
  [types.REQUEST_TEMPLATE_TYPES](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_TEMPLATE_TYPES_ERROR](state) {
    state.isLoading = false;
  },
  [types.RECEIVE_TEMPLATE_TYPES_SUCCESS](state, templates) {
    state.isLoading = false;
    const newTemplates = templates.filter(
      template => !state.templates.find(item => item.key === template.key),
    );
    state.templates = state.templates.concat(newTemplates);
  },
  [types.SET_SELECTED_TEMPLATE_TYPE](state, type) {
    state.selectedTemplateType = type;
    state.templates = [];
  },
  [types.SET_UPDATE_SUCCESS](state, success) {
    state.updateSuccess = success;
  },
};
