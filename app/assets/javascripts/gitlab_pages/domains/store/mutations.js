import * as types from './mutation_types';

export default {
  [types.SET_DOMAIN_ENDPOINT](state, endpoint) {
    state.domainEndpoint = endpoint;
  },

  [types.SET_DOMAIN_NAME](state, name) {
    state.domainName = name;
  },

  [types.REQUEST_DOMAIN](state) {
    state.isLoading = true;
  },

  [types.RECEIVE_DOMAIN_SUCCESS](state, domain) {
    state.isLoading = false;
    state.hasError = false;
    state.domain = domain;

    console.log(domain);
  },

  [types.RECEIVE_DOMAIN_ERROR](state) {
    state.isLoading = false;
    state.hasError = true;
    state.domain = {};
  },
};
