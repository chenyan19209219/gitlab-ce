import _ from 'underscore';
import flash from '~/flash';
import { __, sprintf } from '~/locale';
import service from '../../services';
import api from '../../../api';
import * as types from '../mutation_types';
import router from '../../ide_router';

export const getProjectData = ({ commit, state }, { namespace, projectId, force = false } = {}) =>
  new Promise((resolve, reject) => {
    if (!state.projects[`${namespace}/${projectId}`] || force) {
      commit(types.TOGGLE_LOADING, { entry: state });
      service
        .getProjectData(namespace, projectId)
        .then(res => res.data)
        .then(data => {
          commit(types.TOGGLE_LOADING, { entry: state });
          commit(types.SET_PROJECT, { projectPath: `${namespace}/${projectId}`, project: data });
          commit(types.SET_CURRENT_PROJECT, `${namespace}/${projectId}`);
          resolve(data);
        })
        .catch(() => {
          flash(
            __('Error loading project data. Please try again.'),
            'alert',
            document,
            null,
            false,
            true,
          );
          reject(new Error(`Project not loaded ${namespace}/${projectId}`));
        });
    } else {
      resolve(state.projects[`${namespace}/${projectId}`]);
    }
  });

export const getBranchData = ({ commit, state }, { projectId, branchId, force = false } = {}) =>
  new Promise((resolve, reject) => {
    if (
      typeof state.projects[`${projectId}`] === 'undefined' ||
      !state.projects[`${projectId}`].branches[branchId] ||
      force
    ) {
      service
        .getBranchData(`${projectId}`, branchId)
        .then(({ data }) => {
          const { id } = data.commit;
          commit(types.SET_BRANCH, {
            projectPath: `${projectId}`,
            branchName: branchId,
            branch: data,
          });
          commit(types.SET_BRANCH_WORKING_REFERENCE, { projectId, branchId, reference: id });
          resolve(data);
        })
        .catch(e => {
          if (e.response.status === 404) {
            reject(e);
          } else {
            flash(
              __('Error loading branch data. Please try again.'),
              'alert',
              document,
              null,
              false,
              true,
            );
            reject(new Error(`Branch not loaded - ${projectId}/${branchId}`));
          }
        });
    } else {
      resolve(state.projects[`${projectId}`].branches[branchId]);
    }
  });

export const refreshLastCommitData = ({ commit }, { projectId, branchId } = {}) =>
  service
    .getBranchData(projectId, branchId)
    .then(({ data }) => {
      commit(types.SET_BRANCH_COMMIT, {
        projectId,
        branchId,
        commit: data.commit,
      });
    })
    .catch(() => {
      flash(__('Error loading last commit.'), 'alert', document, null, false, true);
    });

export const createNewBranchFromDefault = ({ state, dispatch, getters }, branch) =>
  api
    .createBranch(state.currentProjectId, {
      ref: getters.currentProject.default_branch,
      branch,
    })
    .then(() => {
      dispatch('setErrorMessage', null);
      router.push(`${router.currentRoute.path}?${Date.now()}`);
    })
    .catch(() => {
      dispatch('setErrorMessage', {
        text: __('An error occurred creating the new branch.'),
        action: payload => dispatch('createNewBranchFromDefault', payload),
        actionText: __('Please try again'),
        actionPayload: branch,
      });
    });

export const showBranchNotFoundError = ({ dispatch }, branchId) => {
  dispatch('setErrorMessage', {
    text: sprintf(
      __("Branch %{branchName} was not found in this project's repository."),
      {
        branchName: `<strong>${_.escape(branchId)}</strong>`,
      },
      false,
    ),
    action: payload => dispatch('createNewBranchFromDefault', payload),
    actionText: __('Create branch'),
    actionPayload: branchId,
  });
};

export const showEmptyState = ({ commit, state }, { err, projectId, branchId }) => {
  if (err.response && err.response.status === 404) {
    commit(types.CREATE_TREE, { treePath: `${projectId}/${branchId}` });
    commit(types.TOGGLE_LOADING, {
      entry: state.trees[`${projectId}/${branchId}`],
      forceValue: false,
    });
  }
};

export const openBranch = ({ dispatch, state }, { projectId, branchId, basePath }) => {
  dispatch('setCurrentBranchId', branchId);

  return dispatch('getBranchData', {
    projectId,
    branchId,
  })
    .then(() => {
      dispatch('getMergeRequestsForBranch', {
        projectId,
        branchId,
      });
      dispatch('getFiles', {
        projectId,
        branchId,
      })
        .then(() => {
          if (basePath) {
            const path = basePath.slice(-1) === '/' ? basePath.slice(0, -1) : basePath;
            const treeEntryKey = Object.keys(state.entries).find(
              key => key === path && !state.entries[key].pending,
            );
            const treeEntry = state.entries[treeEntryKey];

            if (treeEntry) {
              dispatch('handleTreeEntryAction', treeEntry);
            } else {
              dispatch('createTempEntry', {
                name: path,
                type: 'blob',
              });
            }
          }
        })
        .catch(
          () => new Error(`An error occurred whilst getting files for - ${projectId}/${branchId}`),
        );
    })
    .catch(err => {
      // If branch doesn't exist we show empty-state view
      dispatch('showEmptyState', { err, projectId, branchId });
    });
};
