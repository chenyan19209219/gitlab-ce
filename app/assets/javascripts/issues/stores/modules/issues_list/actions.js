import flash from '~/flash';
import { __ } from '~/locale';
import { getParameterValues } from '~/lib/utils/url_utility';
import { ISSUE_STATES } from '../../../constants';
import service from '../../../services/issues_service';
import * as types from './mutation_types';

export const setFilters = ({ commit }, value) => {
  commit(types.SET_FILTERS, value);
};

export const setLoadingState = ({ commit }, value) => {
  commit(types.SET_LOADING_STATE, value);
};

export const setBulkUpdateState = ({ commit }, value) => {
  commit(types.SET_BULK_UPDATE_STATE, value);
};

export const fetchIssues = ({ commit, dispatch, getters }, endpoint) => {
  dispatch('setLoadingState', true);
  const [currentState] = getParameterValues('state');

  // only set state if it does not exist
  const state = !currentState ? ISSUE_STATES.OPENED : null;

  return service
    .fetchIssues(endpoint, getters.appliedFilters, state)
    .then(({ data, headers }) => {
      dispatch('setTotalItems', headers['x-total']);
      dispatch('setCurrentPage', headers['x-page']);
      commit(types.SET_ISSUES_DATA, data);
    })
    .then(() => dispatch('setLoadingState', false))
    .catch(() => flash(__('An error occurred while loading issues')));
};

export const setCurrentPage = ({ commit }, value) => {
  commit(types.SET_CURRENT_PAGE, value);
};

export const setTotalItems = ({ commit }, value) => {
  commit(types.SET_TOTAL_ITEMS, value);
};
