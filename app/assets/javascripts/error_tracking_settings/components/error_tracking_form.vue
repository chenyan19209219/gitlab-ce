<script>
import { mapActions, mapState } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: { Icon },
  props: {
    listProjectsEndpoint: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState({
      showError: state => state.connectError,
      showCheck: state => state.connectSuccessful,
    }),
    apiHost: {
      get() {
        return this.$store.state.apiHost;
      },
      set(apiHost) {
        this.updateApiHost(apiHost);
      },
    },
    enabled: {
      get() {
        return this.$store.state.enabled;
      },
      set(enabled) {
        this.updateEnabled(enabled);
      },
    },
    token: {
      get() {
        return this.$store.state.token;
      },
      set(token) {
        this.updateToken(token);
      },
    },
  },
  methods: {
    ...mapActions(['fetchProjects', 'updateApiHost', 'updateToken', 'updateEnabled']),
    handleConnectClick() {
      this.fetchProjects({
        listProjectsEndpoint: this.listProjectsEndpoint,
      });
    },
  },
};
</script>

<template>
  <div>
    <div class="form-check form-group">
      <input
        id="error-tracking-enabled"
        v-model="enabled"
        class="form-check-input"
        type="checkbox"
      />
      <label class="form-check-label" for="error-tracking-enabled">{{
        s__('ErrorTracking|Active')
      }}</label>
    </div>
    <div class="form-group">
      <label class="label-bold" for="error-tracking-api-host">{{
        s__('ErrorTracking|Sentry API URL')
      }}</label>
      <div class="row">
        <div class="col-8 col-md-9 gl-pr-0">
          <input
            id="error-tracking-api-host"
            v-model="apiHost"
            class="form-control"
            placeholder="https://mysentryserver.com"
          />
        </div>
      </div>
      <p class="form-text text-muted">
        {{ s__('ErrorTracking|Find your hostname in your Sentry account settings page') }}
      </p>
    </div>
    <div class="form-group" :class="{ 'gl-show-field-errors': showError }">
      <label class="label-bold" for="error-tracking-token">{{
        s__('ErrorTracking|Auth Token')
      }}</label>
      <div class="row">
        <div class="col-8 col-md-9 gl-pr-0">
          <input
            id="error-tracking-token"
            v-model="token"
            class="form-control form-control-inline gl-field-error-outline"
          />
        </div>
        <div class="col-4 col-md-3 gl-pl-0">
          <button
            class="btn prepend-left-5"
            data-qa-id="error-tracking-connect"
            @click="handleConnectClick"
          >
            {{ s__('ErrorTracking|Connect') }}
          </button>
          <icon
            v-show="showCheck"
            class="prepend-left-5 text-success align-middle"
            data-qa-id="error-tracking-connect-success"
            :aria-label="__('Projects Successfully Retrieved')"
            name="check-circle"
          />
        </div>
      </div>
      <p v-if="showError" class="gl-field-error">
        {{ s__('ErrorTracking|Connection has failed. Re-check Auth Token and try again.') }}
      </p>
      <p v-else class="form-text text-muted">
        {{ __("After adding your Auth Token, use the 'Connect' button to load projects") }}
      </p>
    </div>
  </div>
</template>
