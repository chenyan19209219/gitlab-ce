import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';
import flash from '~/flash';
import { __ } from '~/locale';

export const setDomainEndpoint = ({ commit }, endpoint) =>
  commit(types.SET_DOMAIN_ENDPOINT, endpoint);

export const setDomainName = ({ commit }, name) => commit(types.SET_DOMAIN_NAME, name);

export const requestDomain = ({ commit }) => commit(types.REQUEST_DOMAIN);

export const fetchDomain = ({ state, dispatch }) => {
  dispatch('requestDomain');

  return axios
    .get(state.domainEndpoint)
    .then(({ data }) => dispatch('receiveDomainSuccess', data))
    .catch(() => dispatch('receiveDomainError'));
};

export const receiveDomainSuccess = ({ commit }, data = {}) => {
  commit(types.RECEIVE_DOMAIN_SUCCESS, data);
};

export const receiveDomainError = ({ commit }) => {
  commit(types.RECEIVE_DOMAIN_ERROR);
  flash(__('An error occurred while fetching the domain details.'));
};
