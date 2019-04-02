import * as types from './mutation_types';

export default {
  [types.SET_LOADING_STATE](state, value) {
    state.loading = value;
  },
  [types.SET_ISSUES_DATA](state, issues) {
    Object.assign(state, {
      issues,
    });
  },
  [types.SET_FILTERS](state, value) {
    state.filters = value;
  },
  [types.SET_BULK_UPDATE_STATE](state, value) {
    state.isBulkUpdating = value;
  },
  [types.SET_TOTAL_ITEMS](state, value) {
    state.totalItems = parseInt(value, 10);
  },
  [types.SET_CURRENT_PAGE](state, value) {
    state.currentPage = parseInt(value, 10);
  },
};
