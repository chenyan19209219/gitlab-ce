<script>
import { s__ } from '~/locale';
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
  computed: {
    ...mapState(['token', 'projects', 'selectedProject']),
    dropdownText() {
      if (this.selectedProject !== null) {
        return this.getDisplayName(this.selectedProject);
      }
      if (!this.areProjectsLoaded || this.isProjectListEmpty) {
        return s__('ErrorTracking|No projects available');
      }
      return s__('ErrorTracking|Select project');
    },
    projectSelectionText() {
      if (this.token) {
        return s__(
          "ErrorTracking|Click 'Connect' to re-establish the connection to Sentry and activate the dropdown.",
        );
      }
      return s__('ErrorTracking|To enable project selection, enter a valid Auth Token');
    },
    isProjectListEmpty() {
      return this.areProjectsLoaded && this.projects.length === 0;
    },
    isProjectInvalid() {
      return (
        this.selectedProject &&
        this.areProjectsLoaded &&
        this.projects.findIndex(item => item.id === this.selectedProject.id) === -1
      );
    },
    areProjectsLoaded() {
      return this.projects.length;
    },
    isDropdownDisabled() {
      return !this.areProjectsLoaded || this.isProjectListEmpty;
    },
  },
  methods: {
    ...mapActions(['updateSelectedProject']),
    handleClick(event) {
      const selectedProject = this.projects.find(item => item.id === event.target.value);

      // Handle the case that the clicked project was not found in the store
      if (selectedProject) {
        this.updateSelectedProject({ ...selectedProject });
      }
    },
    getDisplayName(project) {
      return `${project.organizationName} | ${project.name}`;
    },
  },
};
</script>

<template>
  <div :class="{ 'gl-show-field-errors': isProjectInvalid }">
    <label class="label-bold" for="project-dropdown">{{ __('Project') }}</label>
    <div class="row">
      <gl-dropdown
        id="project-dropdown"
        class="col-8 col-md-9 gl-pr-0"
        :disabled="isDropdownDisabled"
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
    <p v-if="isProjectInvalid" class="gl-field-error" data-qa-id="project-dropdown-error">
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
      data-qa-id="project-dropdown-label"
    >
      {{ projectSelectionText }}
    </p>
  </div>
</template>
