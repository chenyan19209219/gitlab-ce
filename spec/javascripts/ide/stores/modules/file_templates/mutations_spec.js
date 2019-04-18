import state from '~/ide/stores/modules/file_templates/state';
import mutations from '~/ide/stores/modules/file_templates/mutations';
import * as types from '~/ide/stores/modules/file_templates/mutation_types';

const mockFileTemplates = [['MIT'], ['CC']];
const mockTemplateType = 'test';

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

  describe(types.RECEIVE_TEMPLATE_TYPES_SUCCESS, () => {
    it('sets templates loading to false', () => {
      mutations[types.RECEIVE_TEMPLATE_TYPES_SUCCESS](mockedState, mockFileTemplates);

      expect(mockedState.isLoading).toBe(false);
    });

    it('sets templates to payload', () => {
      mutations[types.RECEIVE_TEMPLATE_TYPES_SUCCESS](mockedState, mockFileTemplates);

      expect(mockedState.templates).toEqual(mockFileTemplates);
    });
  });

  describe(types.SET_SELECTED_TEMPLATE_TYPE, () => {
    it('sets templates type to selected type', () => {
      mutations[types.SET_SELECTED_TEMPLATE_TYPE](mockedState, mockTemplateType);

      expect(mockedState.selectedTemplateType).toBe(mockTemplateType);
    });

    it('sets templates to empty array', () => {
      mutations[types.SET_SELECTED_TEMPLATE_TYPE](mockedState, mockTemplateType);

      expect(mockedState.templates).toEqual([]);
    });
  });
});
