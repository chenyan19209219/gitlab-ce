import Vue from 'vue';
import PagesDomainApp from './components/app.vue';

export default () => {
  const el = document.querySelector('.js-pages-domain-app');

  new Vue({
    el,
    components: {
      PagesDomainApp,
    },
    render(createElement) {
      console.log(el);

      return createElement('pages-domain-app', {
        props: {
          example: el.dataset.example,
          domainEndpoint: el.dataset.domainEndpoint,
          domainName: el.dataset.domainName,

          // TODO: pass this info through the API instead
          domainKey: el.dataset.domainKey,
        },
      });
    },
  });
};
