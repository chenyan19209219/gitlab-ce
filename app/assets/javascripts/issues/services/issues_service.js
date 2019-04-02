import axios from '~/lib/utils/axios_utils';

export default {
  fetchIssues(endpoint, filters, state) {
    return axios.get(`${endpoint}${filters}`, {
      params: {
        state,
      },
    });
  },
};
