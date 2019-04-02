import { getParameterValues } from '~/lib/utils/url_utility';

const [page] = getParameterValues('page');

export default () => ({
  loading: false,
  filters: '',
  issues: null,
  isBulkUpdating: false,
  currentPage: page || 1,
  totalItems: 0,
});
