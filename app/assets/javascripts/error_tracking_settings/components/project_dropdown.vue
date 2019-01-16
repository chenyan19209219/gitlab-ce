<script>
import { __, s__ } from '~/locale';
import { mapActions, mapState } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';

import { GlDropdown, GlDropdownHeader, GlDropdownItem } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlDropdownHeader,
    GlDropdownItem,
    Icon,
  },
  noAuthTokenText: __('To enable project selection, enter a valid Auth Token'),
  noConnectionText: __(
    "Click 'Connect' to re-establish the connection to Sentry and activate the dropdown.",
  ),
  noProjectsText: s__('ErrorTracking|No projects available'),
  selectProjectText: s__('ErrorTracking|Select project'),
  computed: {
    ...mapState(['token', 'projects', 'selectedProject']),
    dropdownText() {
      if (this.selectedProject !== null) {
        return this.getDisplayName(this.selectedProject);
      }
      if (!this.areProjectsLoaded || this.isProjectListEmpty) {
        return this.$options.noProjectsText;
      }
      return this.$options.selectProjectText;
    },
    projectSelectionText() {
      if (this.token) {
        return this.$options.noConnectionText;
      }
      return this.$options.noAuthTokenText;
    },
    isProjectListEmpty() {
      return this.areProjectsLoaded && this.projects.length === 0;
    },
    isProjectValid() {
      return (
        this.selectedProject &&
        this.areProjectsLoaded &&
        this.projects.findIndex(item => item.id === this.selectedProject.id) === -1
      );
    },
    areProjectsLoaded() {
      return this.projects !== null;
    },
  },
  methods: {
    ...mapActions(['updateSelectedProject']),
    handleClick(event) {
      this.updateSelectedProject({
        ...this.projects.find(item => item.id === event.target.value),
      });
    },
    getDisplayName(project) {
      return `${project.organizationName} | ${project.name}`;
    },
  },
};
</script>

<template>
  <div :class="[isProjectValid ? 'gl-show-field-errors' : '']">
    <label class="label-bold" for="project_dropdown">{{ s__('ErrorTracking|Project') }}</label>
    <div class="row">
      <gl-dropdown
        id="project_dropdown"
        class="col-8 col-md-9 gl-pr-0"
        :disabled="!areProjectsLoaded || isProjectListEmpty"
        menu-class="w-100 mw-100"
        toggle-class="dropdown-menu-toggle w-100 gl-field-error-outline"
        :text="dropdownText"
      >
        <gl-dropdown-item
          v-for="project in projects"
          :key="project.id"
          :value="project.id"
          class="w-100"
          @click="handleClick"
          >{{ getDisplayName(project) }}</gl-dropdown-item
        >
      </gl-dropdown>
    </div>
    <p v-if="isProjectValid" class="gl-field-error" data-qa-id="project_dropdown_error">
      {{
        sprintf(
          __('Project "%{name}" is no longer available. Select another project to continue.'),
          { name: selectedProject.name },
        )
      }}
    </p>
    <p
      v-else-if="!areProjectsLoaded"
      class="form-text text-muted"
      data-qa-id="project_dropdown_label"
    >
      {{ projectSelectionText }}
    </p>
  </div>
</template>
