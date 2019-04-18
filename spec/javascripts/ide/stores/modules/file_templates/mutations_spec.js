import state from '~/ide/stores/modules/file_templates/state';
import mutations from '~/ide/stores/modules/file_templates/mutations';
import * as types from '~/ide/stores/modules/file_templates/mutation_types';

describe('IDE file templates mutations', () => {
  let mockedState;

  beforeEach(() => {
    mockedState = state();
  });

  describe(types.REQUEST_TEMPLATE_TYPES, () => {
    it('sets loading to true', () => {
      mutations[types.REQUEST_TEMPLATE_TYPES](mockedState);

      expect(mockedState.isLoading).toBe(true);
    });

    it('sets templates to an empty array', () => {
      mutations[types.REQUEST_TEMPLATE_TYPES](mockedState);

      expect(mockedState.templates).toEqual([]);
    });
  });

  describe(types.RECEIVE_TEMPLATE_TYPES_ERROR, () => {
    it('sets loading to false', () => {
      mutations[types.RECEIVE_TEMPLATE_TYPES_ERROR](mockedState);

      expect(mockedState.isLoading).toBe(false);
    });
  });
});
