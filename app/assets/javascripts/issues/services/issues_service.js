import axios from '~/lib/utils/axios_utils';

export default {
  fetchIssues(endpoint, filters, page) {
    return axios.get(`${endpoint}${filters}`, {
      params: {
        page,
      },
    });
  },
};
