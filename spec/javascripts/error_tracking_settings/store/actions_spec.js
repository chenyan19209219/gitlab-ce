import MockAdapter from 'axios-mock-adapter';
import testAction from 'spec/helpers/vuex_action_helper';
import * as actions from '~/error_tracking_settings/store/actions';
import * as types from '~/error_tracking_settings/store/mutation_types';
import axios from '~/lib/utils/axios_utils';
import { TEST_HOST } from 'spec/test_constants';
import { transformBackendProject } from '~/error_tracking_settings/store/utils';

const projects = [
  {
    name: 'name',
    slug: 'slug',
    organization_name: 'organizationName',
    organization_slug: 'organizationSlug',
  },
];

describe('ErrorTrackingActions', () => {
  let state;

  describe('Project list actions', () => {
    let mock;

    beforeEach(() => {
      mock = new MockAdapter(axios);
      state = {
        api_host: '',
        token: '',
      };
    });

    afterEach(() => {
      mock.restore();
    });

    it('should request and transform the project list', done => {
      mock.onPost(`${TEST_HOST}.json`).reply(() => [200, { projects }]);
      testAction(
        actions.fetchProjects,
        { listProjectsEndpoint: TEST_HOST },
        state,
        [],
        [
          { type: 'requestProjects' },
          {
            type: 'receiveProjectsSuccess',
            payload: projects.map(transformBackendProject),
          },
        ],
        () => {
          expect(mock.history.post.length).toBe(1);
          done();
        },
      );
    });

    it('should handle a server error', done => {
      mock.onPost(`${TEST_HOST}.json`).reply(() => [400]);
      testAction(
        actions.fetchProjects,
        { listProjectsEndpoint: TEST_HOST },
        state,
        [],
        [
          { type: 'requestProjects' },
          {
            type: 'receiveProjectsError',
          },
        ],
        () => {
          expect(mock.history.post.length).toBe(1);
          done();
        },
      );
    });

    it('should request projects correctly', done => {
      testAction(actions.requestProjects, null, state, [{ type: types.RESET_CONNECT }], [], done);
    });

    it('should receive projects correctly', done => {
      const testPayload = [];
      testAction(
        actions.receiveProjectsSuccess,
        testPayload,
        state,
        [
          { type: types.UPDATE_CONNECT_SUCCESS },
          { type: types.RECEIVE_PROJECTS, payload: testPayload },
        ],
        [],
        done,
      );
    });

    it('should handle errors when receiving projects', done => {
      const testPayload = [];
      testAction(
        actions.receiveProjectsError,
        testPayload,
        state,
        [{ type: types.UPDATE_CONNECT_ERROR }, { type: types.RECEIVE_PROJECTS, payload: null }],
        [],
        done,
      );
    });
  });

  describe('Save changes actions', () => {
    let mock;

    beforeEach(() => {
      mock = new MockAdapter(axios);
      state = {
        api_host: '',
        token: '',
      };
    });

    afterEach(() => {
      mock.restore();
    });

    it('should save the page', done => {
      mock.onPatch(TEST_HOST).reply(200);
      testAction(
        actions.updateSettings,
        { operationsSettingsEndpoint: TEST_HOST },
        state,
        [],
        [{ type: 'requestSettings' }, { type: 'receiveSettingsSuccess' }],
        () => {
          expect(mock.history.patch.length).toBe(1);
          done();
        },
      );
    });

    it('should handle a server error', done => {
      mock.onPatch(TEST_HOST).reply(400);
      testAction(
        actions.updateSettings,
        { operationsSettingsEndpoint: TEST_HOST },
        state,
        [],
        [
          { type: 'requestSettings' },
          {
            type: 'receiveSettingsError',
            payload: new Error('Request failed with status code 400'),
          },
        ],
        () => {
          expect(mock.history.patch.length).toBe(1);
          done();
        },
      );
    });

    it('should request to save the page', done => {
      testAction(
        actions.requestSettings,
        null,
        state,
        [{ type: types.UPDATE_SETTINGS_LOADING, payload: true }],
        [],
        done,
      );
    });

    it('should request to save the page correctly', done => {
      testAction(
        actions.receiveSettingsSuccess,
        null,
        state,
        [{ type: types.UPDATE_SETTINGS_LOADING, payload: false }],
        [],
        done,
      );
    });

    it('should handle errors when requesting to save the page', done => {
      testAction(
        actions.receiveSettingsError,
        {},
        state,
        [{ type: types.UPDATE_SETTINGS_LOADING, payload: false }],
        [],
        done,
      );
    });
  });

  describe('Generic actions to update the store', () => {
    const testData = 'test';
    it('should reset the `connect success` flag when updating the api host', done => {
      testAction(
        actions.updateApiHost,
        testData,
        state,
        [{ type: types.UPDATE_API_HOST, payload: testData }, { type: types.RESET_CONNECT }],
        [],
        done,
      );
    });

    it('should reset the `connect success` flag when updating the token', done => {
      testAction(
        actions.updateToken,
        testData,
        state,
        [{ type: types.UPDATE_TOKEN, payload: testData }, { type: types.RESET_CONNECT }],
        [],
        done,
      );
    });
  });
});
