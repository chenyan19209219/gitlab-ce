import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import ErrorTrackingForm from '~/error_tracking_settings/components/error_tracking_form.vue';
import { TEST_HOST } from 'spec/test_constants';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ErrorTrackingSettings', () => {
  let store;
  let wrapper;

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
    const actions = {};

    const state = {
      token: '',
      apiHost: '',
      connectSuccessful: false,
      connectError: false,
    };

    store = new Vuex.Store({
      actions,
      state,
    });

    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('Empty form', () => {
    it('renders the form', () => {
      expect(wrapper.find('#error_tracking_enabled').exists()).toBeTruthy();
      expect(wrapper.find('#error_tracking_api_host').exists()).toBeTruthy();
      expect(wrapper.find('#error_tracking_token').exists()).toBeTruthy();
      expect(wrapper.find('[data-qa-id=error_tracking_connect]').exists()).toBeTruthy();
    });

    it('renders labels', () => {
      const pageText = wrapper.text();

      expect(pageText).toContain('Active');
      expect(pageText).toContain('Find your hostname in your Sentry account settings page');
      expect(pageText).toContain(
        "After adding your Auth Token, use the 'Connect' button to load projects",
      );

      expect(pageText).not.toContain('Connection has failed. Re-check Auth Token and try again');
      expect(wrapper.find('#error_tracking_api_host').attributes('placeholder')).toContain(
        'https://mysentryserver.com',
      );
    });
  });

  describe('After a successful connection', () => {
    beforeEach(() => {
      store.state.connectSuccessful = true;
      store.state.connectError = false;
    });

    it('shows the success checkmark', () => {
      expect(wrapper.find('[data-qa-id=error_tracking_connect_success]').isVisible()).toBeTruthy();
    });

    it('does not show an error', () => {
      expect(wrapper.text()).not.toContain(
        'Connection has failed. Re-check Auth Token and try again',
      );
    });
  });

  describe('After an unsuccessful connection', () => {
    beforeEach(() => {
      store.state.connectSuccessful = false;
      store.state.connectError = true;
    });

    it('does not show the check mark', () => {
      expect(wrapper.find('[data-qa-id=error_tracking_connect_success]').isVisible()).toBeFalsy();
    });

    it('shows an error', () => {
      expect(wrapper.text()).toContain('Connection has failed. Re-check Auth Token and try again');
    });
  });
});
