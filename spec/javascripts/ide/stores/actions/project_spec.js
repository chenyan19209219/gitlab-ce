import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import {
  refreshLastCommitData,
  createNewBranchFromDefault,
  getBranchData,
  showEmptyState,
  openBranch,
} from '~/ide/stores/actions';
import store from '~/ide/stores';
import service from '~/ide/services';
import api from '~/api';
import router from '~/ide/ide_router';
import { resetStore } from '../../helpers';
import testAction from '../../../helpers/vuex_action_helper';

describe('IDE store project actions', () => {
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);

    store.state.projects['abc/def'] = {
      branches: {},
    };
  });

  afterEach(() => {
    mock.restore();

    resetStore(store);
  });

  describe('refreshLastCommitData', () => {
    beforeEach(() => {
      store.state.currentProjectId = 'abc/def';
      store.state.currentBranchId = 'master';
      store.state.projects['abc/def'] = {
        id: 4,
        branches: {
          master: {
            commit: null,
          },
        },
      };
      spyOn(service, 'getBranchData').and.returnValue(
        Promise.resolve({
          data: {
            commit: { id: '123' },
          },
        }),
      );
    });

    it('calls the service', done => {
      store
        .dispatch('refreshLastCommitData', {
          projectId: store.state.currentProjectId,
          branchId: store.state.currentBranchId,
        })
        .then(() => {
          expect(service.getBranchData).toHaveBeenCalledWith('abc/def', 'master');

          done();
        })
        .catch(done.fail);
    });

    it('commits getBranchData', done => {
      testAction(
        refreshLastCommitData,
        {
          projectId: store.state.currentProjectId,
          branchId: store.state.currentBranchId,
        },
        store.state,
        // mutations
        [
          {
            type: 'SET_BRANCH_COMMIT',
            payload: {
              projectId: 'abc/def',
              branchId: 'master',
              commit: { id: '123' },
            },
          },
        ],
        // action
        [],
        done,
      );
    });
  });

  describe('createNewBranchFromDefault', () => {
    it('calls API', done => {
      spyOn(api, 'createBranch').and.returnValue(Promise.resolve());
      spyOn(router, 'push');

      createNewBranchFromDefault(
        {
          state: {
            currentProjectId: 'project-path',
          },
          getters: {
            currentProject: {
              default_branch: 'master',
            },
          },
          dispatch() {},
        },
        'new-branch-name',
      )
        .then(() => {
          expect(api.createBranch).toHaveBeenCalledWith('project-path', {
            ref: 'master',
            branch: 'new-branch-name',
          });
        })
        .then(done)
        .catch(done.fail);
    });

    it('clears error message', done => {
      const dispatchSpy = jasmine.createSpy('dispatch');
      spyOn(api, 'createBranch').and.returnValue(Promise.resolve());
      spyOn(router, 'push');

      createNewBranchFromDefault(
        {
          state: {
            currentProjectId: 'project-path',
          },
          getters: {
            currentProject: {
              default_branch: 'master',
            },
          },
          dispatch: dispatchSpy,
        },
        'new-branch-name',
      )
        .then(() => {
          expect(dispatchSpy).toHaveBeenCalledWith('setErrorMessage', null);
        })
        .then(done)
        .catch(done.fail);
    });

    it('reloads window', done => {
      spyOn(api, 'createBranch').and.returnValue(Promise.resolve());
      spyOn(router, 'push');

      createNewBranchFromDefault(
        {
          state: {
            currentProjectId: 'project-path',
          },
          getters: {
            currentProject: {
              default_branch: 'master',
            },
          },
          dispatch() {},
        },
        'new-branch-name',
      )
        .then(() => {
          expect(router.push).toHaveBeenCalled();
        })
        .then(done)
        .catch(done.fail);
    });
  });

  describe('getBranchData', () => {
    describe('error', () => {
      let dispatch;
      const callParams = [
        {
          commit() {},
          dispatch,
          state: store.state,
        },
        {
          projectId: 'abc/def',
          branchId: 'master-testing',
        },
      ];

      beforeEach(() => {
        dispatch = jasmine.createSpy('dispatchSpy');
        document.body.innerHTML += '<div class="flash-container"></div>';
      });

      afterEach(() => {
        document.querySelector('.flash-container').remove();
      });

      it('passes the error further unchanged without dispatching any action when response is 404', done => {
        mock.onGet(/(.*)/).replyOnce(404);

        getBranchData(...callParams)
          .then(done.fail)
          .catch(e => {
            expect(dispatch.calls.count()).toEqual(0);
            expect(e.response.status).toEqual(404);
            expect(document.querySelector('.flash-alert')).toBeNull();
            done();
          });
      });

      it('does not pass the error further and flashes an alert if error is not 404', done => {
        mock.onGet(/(.*)/).replyOnce(418);

        getBranchData(...callParams)
          .then(done.fail)
          .catch(e => {
            expect(dispatch.calls.count()).toEqual(0);
            expect(e.response).toBeUndefined();
            expect(document.querySelector('.flash-alert')).not.toBeNull();
            done();
          });
      });
    });
  });

  describe('showEmptyState', () => {
    it('does nothing if error is not 404', done => {
      testAction(
        showEmptyState,
        {
          err: {
            response: {
              status: 418,
            },
          },
          projectId: 'abc/def',
          branchId: 'master',
        },
        store.state,
        [],
        [],
        done,
      );
    });

    it('commits proper mutations when supplied error is 404', done => {
      testAction(
        showEmptyState,
        {
          err: {
            response: {
              status: 404,
            },
          },
          projectId: 'abc/def',
          branchId: 'master',
        },
        store.state,
        [
          {
            type: 'CREATE_TREE',
            payload: {
              treePath: 'abc/def/master',
            },
          },
          {
            type: 'TOGGLE_LOADING',
            payload: {
              entry: store.state.trees['abc/def/master'],
              forceValue: false,
            },
          },
        ],
        [],
        done,
      );
    });
  });

  describe('openBranch', () => {
    const branch = {
      projectId: 'feature/lorem-ipsum',
      branchId: '123-lorem',
    };

    beforeEach(() => {
      store.state.entries = {
        foo: { pending: false },
        'foo/bar-pending': { pending: true },
        'foo/bar': { pending: false },
      };
    });

    describe('existing branch', () => {
      beforeEach(() => {
        spyOn(store, 'dispatch').and.returnValue(Promise.resolve());
      });

      it('dispatches branch actions', done => {
        openBranch(store, branch)
          .then(() => {
            expect(store.dispatch.calls.allArgs()).toEqual([
              ['setCurrentBranchId', branch.branchId],
              ['getBranchData', branch],
              ['getMergeRequestsForBranch', branch],
              ['getFiles', branch],
            ]);
          })
          .then(done)
          .catch(done.fail);
      });

      it('handles tree entry action, if basePath is given', done => {
        openBranch(store, { ...branch, basePath: 'foo/bar/' })
          .then(() => {
            expect(store.dispatch).toHaveBeenCalledWith(
              'handleTreeEntryAction',
              store.state.entries['foo/bar'],
            );
          })
          .then(done)
          .catch(done.fail);
      });

      it('does not handle tree entry action, if entry is pending', done => {
        openBranch(store, { ...branch, basePath: 'foo/bar-pending' })
          .then(() => {
            expect(store.dispatch).not.toHaveBeenCalledWith(
              'handleTreeEntryAction',
              jasmine.anything(),
            );
          })
          .then(done)
          .catch(done.fail);
      });

      it('creates a new file supplied via URL if the file does not exist yet', done => {
        openBranch(store, { ...branch, basePath: 'not-existent.md' })
          .then(() => {
            expect(store.dispatch).not.toHaveBeenCalledWith(
              'handleTreeEntryAction',
              jasmine.anything(),
            );

            expect(store.dispatch).toHaveBeenCalledWith('createTempEntry', {
              name: 'not-existent.md',
              type: 'blob',
            });
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('non-existent branch', () => {
      beforeEach(() => {
        spyOn(store, 'dispatch').and.returnValue(Promise.reject());
      });

      afterEach(() => {
        mock.restore();
      });

      it('dispatches correct branch actions', done => {
        openBranch(store, branch)
          .then(() => {
            expect(store.dispatch.calls.allArgs()).toEqual([
              ['setCurrentBranchId', branch.branchId],
              ['getBranchData', branch],
              [
                'showEmptyState',
                { err: undefined, branchId: branch.branchId, projectId: branch.projectId },
              ],
            ]);
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });
});
