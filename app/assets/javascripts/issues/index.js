import Vue from 'vue';
import IssuesApp from './components/issues_app.vue';

export default () => {
  const el = document.querySelector('#js-issues-list');
  
  if (!el) return null;

  const issues = JSON.parse(el.dataset.issues);

  return new Vue({
    el,
    components: {
      IssuesApp,
    },
    render(createElement) {
      return createElement('issues-app', {
        props: {
          issues,
        },
      });
    },
  });
};
