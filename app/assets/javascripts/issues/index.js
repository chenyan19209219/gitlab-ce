import Vue from 'vue';
import store from './stores';
import IssuesApp from './components/issues_app.vue';

export default () => {
  const el = document.querySelector('#js-issues-list');

  if (!el) return null;

  const { endpoint } = el.dataset;

  return new Vue({
    el,
    store,
    components: {
      IssuesApp,
    },
    render(createElement) {
      return createElement('issues-app', {
        props: {
          endpoint,
        },
      });
    },
  });
};
