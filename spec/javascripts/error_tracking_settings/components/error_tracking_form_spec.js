import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import ErrorTrackingForm from '~/error_tracking_settings/components/error_tracking_form.vue';
import { createStore } from '~/error_tracking_settings/store';
import { TEST_HOST } from 'spec/test_constants';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('error tracking settings form', () => {
  let wrapper;
  let store;

  function mountComponent() {
    wrapper = shallowMount(ErrorTrackingForm, {
      localVue,
      store,
      propsData: {
        listProjectsEndpoint: TEST_HOST,
      },
    });
  }

  beforeEach(() => {
    store = createStore();
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('empty form', () => {
    it('renders the form', () => {
      expect(wrapper.find('#error-tracking-enabled').exists()).toBeTruthy();
      expect(wrapper.find('#error-tracking-api-host').exists()).toBeTruthy();
      expect(wrapper.find('#error-tracking-token').exists()).toBeTruthy();
      expect(wrapper.find('[data-qa-id=error-tracking-connect]').exists()).toBeTruthy();
    });

    it('renders labels', () => {
      const pageText = wrapper.text();

      expect(pageText).toContain('Active');
      expect(pageText).toContain('Find your hostname in your Sentry account settings page');
      expect(pageText).toContain(
        "After adding your Auth Token, use the 'Connect' button to load projects",
      );

      expect(pageText).not.toContain('Connection has failed. Re-check Auth Token and try again');
      expect(wrapper.find('#error-tracking-api-host').attributes('placeholder')).toContain(
        'https://mysentryserver.com',
      );
    });
  });

  describe('after a successful connection', () => {
    beforeEach(() => {
      store.state.connectSuccessful = true;
      store.state.connectError = false;
    });

    it('shows the success checkmark', () => {
      expect(wrapper.find('[data-qa-id=error-tracking-connect-success]').isVisible()).toBeTruthy();
    });

    it('does not show an error', () => {
      expect(wrapper.text()).not.toContain(
        'Connection has failed. Re-check Auth Token and try again',
      );
    });
  });

  describe('after an unsuccessful connection', () => {
    beforeEach(() => {
      store.state.connectSuccessful = false;
      store.state.connectError = true;
    });

    it('does not show the check mark', () => {
      expect(wrapper.find('[data-qa-id=error-tracking-connect-success]').isVisible()).toBeFalsy();
    });

    it('shows an error', () => {
      expect(wrapper.text()).toContain('Connection has failed. Re-check Auth Token and try again');
    });
  });
});
