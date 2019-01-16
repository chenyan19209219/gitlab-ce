<script>
import { mapActions } from 'vuex';
import projectDropdown from './project_dropdown.vue';
import errorTrackingForm from './error_tracking_form.vue';

export default {
  components: { projectDropdown, errorTrackingForm },
  props: {
    listProjectsEndpoint: {
      type: String,
      required: true,
    },
    operationsSettingsEndpoint: {
      type: String,
      required: true,
    },
  },
  methods: {
    ...mapActions(['updateSettings']),
    handleSubmit() {
      this.updateSettings({
        operationsSettingsEndpoint: this.operationsSettingsEndpoint,
      });
    },
  },
};
</script>

<template>
  <div>
    <error-tracking-form :list-projects-endpoint="listProjectsEndpoint" />
    <div class="form-group">
      <project-dropdown />
    </div>
    <button
      :disabled="$store.state.settingsLoading"
      class="btn btn-success"
      data-qa-id="error_tracking_button"
      @click="handleSubmit"
    >
      {{ __('Save changes') }}
    </button>
  </div>
</template>
