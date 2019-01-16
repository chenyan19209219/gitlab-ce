import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import ErrorTrackingSettings from '~/error_tracking_settings/components/error_tracking_settings.vue';
import ErrorTrackingForm from '~/error_tracking_settings/components/error_tracking_form.vue';
import ProjectDropdown from '~/error_tracking_settings/components/project_dropdown.vue';
import { TEST_HOST } from 'spec/test_constants';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ErrorTrackingSettings', () => {
  let store;
  let wrapper;

  function mountComponent() {
    wrapper = shallowMount(ErrorTrackingSettings, {
      localVue,
      store,
      propsData: {
        listProjectsEndpoint: TEST_HOST,
        operationsSettingsEndpoint: TEST_HOST,
      },
    });
  }

  beforeEach(() => {
    const actions = {};
    const state = {
      settingsLoading: false,
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

  describe('Section', () => {
    it('renders the form and dropdown', () => {
      expect(wrapper.find(ErrorTrackingForm).exists()).toBeTruthy();
      expect(wrapper.find(ProjectDropdown).exists()).toBeTruthy();
    });

    it('renders the Save Changes button', () => {
      expect(wrapper.find('[data-qa-id=error_tracking_button').exists()).toBeTruthy();
    });

    it('enables the button by default', () => {
      expect(wrapper.find('[data-qa-id=error_tracking_button').attributes('disabled')).toBeFalsy();
    });

    it('disables the button when saving', () => {
      store.state.settingsLoading = true;

      expect(wrapper.find('[data-qa-id=error_tracking_button').attributes('disabled')).toBeTruthy();
    });
  });
});
