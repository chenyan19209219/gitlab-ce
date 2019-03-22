import Vue from 'vue';
import Vuex from 'vuex';
import issuesList from './modules/issues_list';

Vue.use(Vuex);

export const createStore = () =>
  new Vuex.Store({
    modules: {
      issuesList: issuesList(),
    },
  });

export default createStore();
