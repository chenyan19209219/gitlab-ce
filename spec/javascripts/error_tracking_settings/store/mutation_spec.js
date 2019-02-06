import mutations from '~/error_tracking_settings/store/mutations';
import * as types from '~/error_tracking_settings/store/mutation_types';

describe('error tracking settings mutations', () => {
  describe('mutations', () => {
    let state;

    beforeEach(() => {
      state = { connectSuccessful: false, connectError: false };
    });

    it('should update state when connect is successful', () => {
      mutations[types.UPDATE_CONNECT_SUCCESS](state);

      expect(state.connectSuccessful).toBe(true);
      expect(state.connectError).toBe(false);
    });

    it('should update state when connect fails', () => {
      mutations[types.UPDATE_CONNECT_ERROR](state);

      expect(state.connectSuccessful).toBe(false);
      expect(state.connectError).toBe(true);
    });

    it('should update state when connect is reset', () => {
      mutations[types.RESET_CONNECT](state);

      expect(state.connectSuccessful).toBe(false);
      expect(state.connectError).toBe(false);
    });
  });
});
