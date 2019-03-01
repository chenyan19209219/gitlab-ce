import Vue from 'vue';
import variableListApp from './components/variable_settings.vue';

export default () =>
  new Vue({
    el: document.getElementById('js-ci-variable-list-section'),
    components: {
      variableListApp,
    },
    data() {
      return {
        endpoint: this.$options.el.dataset.endpoint,
        projectId: this.$options.el.dataset.project_id,
      };
    },
    render(createElement) {
      return createElement('variable-list-app', {
        props: {
          endpoint: this.endpoint,
          projectId: this.projectId,
        },
      });
    },
  });
