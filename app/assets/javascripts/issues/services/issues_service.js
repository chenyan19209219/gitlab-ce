import axios from '~/lib/utils/axios_utils';

export default {
  fetchIssues(endpoint, filters) {
    return axios.get(`${endpoint}${filters}`);
  },
};
