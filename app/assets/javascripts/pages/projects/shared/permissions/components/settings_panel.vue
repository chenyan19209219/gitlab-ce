<script>
import { __ } from '~/locale';
import projectFeatureSetting from './project_feature_setting.vue';
import projectFeatureToggle from '../../../../../vue_shared/components/toggle_button.vue';
import projectSettingRow from './project_setting_row.vue';
import {
  visibilityOptions,
  forkingAccessLevelOptions,
  visibilityLevelDescriptions,
  forkingAccessLevelDescriptions,
} from '../constants';
import { toggleHiddenClassBySelector } from '../external';

export default {
  components: {
    projectFeatureSetting,
    projectFeatureToggle,
    projectSettingRow,
  },

  props: {
    currentSettings: {
      type: Object,
      required: true,
    },
    canChangeVisibilityLevel: {
      type: Boolean,
      required: false,
      default: false,
    },
    allowedVisibilityOptions: {
      type: Array,
      required: false,
      default: () => [0, 10, 20],
    },
    lfsAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
    registryAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
    visibilityHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    lfsHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    registryHelpPath: {
      type: String,
      required: false,
      default: '',
    },
    pagesAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
    pagesAccessControlEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    pagesHelpPath: {
      type: String,
      required: false,
      default: '',
    },
  },

  data() {
    const defaults = {
      visibilityOptions,
      visibilityLevel: visibilityOptions.PUBLIC,
      issuesAccessLevel: 20,
      repositoryAccessLevel: 20,
      mergeRequestsAccessLevel: 20,
      buildsAccessLevel: 20,
      wikiAccessLevel: 20,
      snippetsAccessLevel: 20,
      pagesAccessLevel: 20,
      forkingAccessLevel: forkingAccessLevelOptions.PRIVATE_FORKS_ONLY,
      containerRegistryEnabled: true,
      lfsEnabled: true,
      requestAccessEnabled: true,
      highlightChangesClass: false,
    };

    return { ...defaults, ...this.currentSettings };
  },

  computed: {
    featureAccessLevelOptions() {
      const options = [[10, __('Only Project Members')]];
      if (this.visibilityLevel !== visibilityOptions.PRIVATE) {
        options.push([20, __('Everyone With Access')]);
      }
      return options;
    },

    repoFeatureAccessLevelOptions() {
      return this.featureAccessLevelOptions.filter(
        ([value]) => value <= this.repositoryAccessLevel,
      );
    },

    pagesFeatureAccessLevelOptions() {
      if (this.visibilityLevel !== visibilityOptions.PUBLIC) {
        return this.featureAccessLevelOptions.concat([[30, __('Everyone')]]);
      }
      return this.featureAccessLevelOptions;
    },

    forkingLevelOptions() {
      return [
        [
          forkingAccessLevelOptions.ALLOW_FORKS,
          forkingAccessLevelDescriptions[forkingAccessLevelOptions.ALLOW_FORKS],
        ],
        [
          forkingAccessLevelOptions.PRIVATE_FORKS_ONLY,
          forkingAccessLevelDescriptions[forkingAccessLevelOptions.PRIVATE_FORKS_ONLY],
        ],
      ];
    },

    repositoryEnabled() {
      return this.repositoryAccessLevel > 0;
    },

    visibilityLevelDescription() {
      return visibilityLevelDescriptions[this.visibilityLevel];
    },

    isPrivateProject() {
      return this.visibilityLevel === visibilityOptions.PRIVATE;
    },

    isInternalProject() {
      return this.visibilityLevel === visibilityOptions.INTERNAL;
    },

    showForkingAccessLevel() {
      return (
        gon.features &&
        gon.features.showForkingAccessLevel &&
        (this.isPrivateProject || this.isInternalProject)
      );
    },
  },

  watch: {
    visibilityLevel(value, oldValue) {
      if (value === visibilityOptions.PRIVATE) {
        // when private, features are restricted to "only team members"
        this.issuesAccessLevel = Math.min(10, this.issuesAccessLevel);
        this.repositoryAccessLevel = Math.min(10, this.repositoryAccessLevel);
        this.mergeRequestsAccessLevel = Math.min(10, this.mergeRequestsAccessLevel);
        this.buildsAccessLevel = Math.min(10, this.buildsAccessLevel);
        this.wikiAccessLevel = Math.min(10, this.wikiAccessLevel);
        this.snippetsAccessLevel = Math.min(10, this.snippetsAccessLevel);
        if (this.pagesAccessLevel === 20) {
          // When from Internal->Private narrow access for only members
          this.pagesAccessLevel = 10;
        }
        this.forkingAccessLevel = forkingAccessLevelOptions.PRIVATE_FORKS_ONLY;
        this.highlightChanges();
      } else if (oldValue === visibilityOptions.PRIVATE) {
        // if changing away from private, make enabled features more permissive
        if (this.issuesAccessLevel > 0) this.issuesAccessLevel = 20;
        if (this.repositoryAccessLevel > 0) this.repositoryAccessLevel = 20;
        if (this.mergeRequestsAccessLevel > 0) this.mergeRequestsAccessLevel = 20;
        if (this.buildsAccessLevel > 0) this.buildsAccessLevel = 20;
        if (this.wikiAccessLevel > 0) this.wikiAccessLevel = 20;
        if (this.snippetsAccessLevel > 0) this.snippetsAccessLevel = 20;
        if (this.pagesAccessLevel === 10) this.pagesAccessLevel = 20;
        this.highlightChanges();
      }
    },

    repositoryAccessLevel(value, oldValue) {
      if (value < oldValue) {
        // sub-features cannot have more premissive access level
        this.mergeRequestsAccessLevel = Math.min(this.mergeRequestsAccessLevel, value);
        this.buildsAccessLevel = Math.min(this.buildsAccessLevel, value);

        if (value === 0) {
          this.containerRegistryEnabled = false;
          this.lfsEnabled = false;
        }
      } else if (oldValue === 0) {
        this.mergeRequestsAccessLevel = value;
        this.buildsAccessLevel = value;
        this.containerRegistryEnabled = true;
        this.lfsEnabled = true;
      }
    },

    issuesAccessLevel(value, oldValue) {
      if (value === 0) toggleHiddenClassBySelector('.issues-feature', true);
      else if (oldValue === 0) toggleHiddenClassBySelector('.issues-feature', false);
    },

    mergeRequestsAccessLevel(value, oldValue) {
      if (value === 0) toggleHiddenClassBySelector('.merge-requests-feature', true);
      else if (oldValue === 0) toggleHiddenClassBySelector('.merge-requests-feature', false);
    },

    buildsAccessLevel(value, oldValue) {
      if (value === 0) toggleHiddenClassBySelector('.builds-feature', true);
      else if (oldValue === 0) toggleHiddenClassBySelector('.builds-feature', false);
    },
  },

  methods: {
    highlightChanges() {
      this.highlightChangesClass = true;
      this.$nextTick(() => {
        this.highlightChangesClass = false;
      });
    },

    visibilityAllowed(option) {
      return this.allowedVisibilityOptions.includes(option);
    },
  },
};
</script>

<template>
  <div>
    <div class="project-visibility-setting">
      <project-setting-row :help-path="visibilityHelpPath" :label="__('Project visibility')">
        <div class="project-feature-controls">
          <div class="select-wrapper">
            <select
              v-model="visibilityLevel"
              :disabled="!canChangeVisibilityLevel"
              name="project[visibility_level]"
              class="form-control select-control"
            >
              <option
                :value="visibilityOptions.PRIVATE"
                :disabled="!visibilityAllowed(visibilityOptions.PRIVATE)"
              >
                {{ __('Private') }}
              </option>
              <option
                :value="visibilityOptions.INTERNAL"
                :disabled="!visibilityAllowed(visibilityOptions.INTERNAL)"
              >
                {{ __('Internal') }}
              </option>
              <option
                :value="visibilityOptions.PUBLIC"
                :disabled="!visibilityAllowed(visibilityOptions.PUBLIC)"
              >
                {{ __('Public') }}
              </option>
            </select>
            <i aria-hidden="true" data-hidden="true" class="fa fa-chevron-down"> </i>
          </div>
        </div>
        <span class="form-text text-muted">{{ visibilityLevelDescription }}</span>
        <label v-if="!isPrivateProject" class="request-access">
          <input
            :value="requestAccessEnabled"
            type="hidden"
            name="project[request_access_enabled]"
          />
          <input v-model="requestAccessEnabled" type="checkbox" />
          {{ __('Allow users to request access') }}
        </label>
      </project-setting-row>
    </div>
    <div :class="{ 'highlight-changes': highlightChangesClass }" class="project-feature-settings">
      <project-setting-row
        :label="__('Issues')"
        :help-text="__('Lightweight issue tracking system for this project')"
      >
        <project-feature-setting
          v-model="issuesAccessLevel"
          :options="featureAccessLevelOptions"
          name="project[project_feature_attributes][issues_access_level]"
        />
      </project-setting-row>
      <project-setting-row
        :label="__('Repository')"
        :help-text="__('View and edit files in this project')"
      >
        <project-feature-setting
          v-model="repositoryAccessLevel"
          :options="featureAccessLevelOptions"
          name="project[project_feature_attributes][repository_access_level]"
        />
      </project-setting-row>
      <div class="project-feature-setting-group">
        <project-setting-row
          :label="__('Merge requests')"
          :help-text="__('Submit changes to be merged upstream')"
        >
          <project-feature-setting
            v-model="mergeRequestsAccessLevel"
            :options="repoFeatureAccessLevelOptions"
            :disabled-input="!repositoryEnabled"
            name="project[project_feature_attributes][merge_requests_access_level]"
          />
        </project-setting-row>
        <project-setting-row
          :label="__('Pipelines')"
          :help-text="__('Build, test, and deploy your changes')"
        >
          <project-feature-setting
            v-model="buildsAccessLevel"
            :options="repoFeatureAccessLevelOptions"
            :disabled-input="!repositoryEnabled"
            name="project[project_feature_attributes][builds_access_level]"
          />
        </project-setting-row>
        <project-setting-row
          v-if="showForkingAccessLevel"
          :help-tooltip-text="
            __(
              'Allowing only private forks will force the visibility of new forks to Private. Existing forks will not be affected.',
            )
          "
          :label="__('Forks')"
          :help-text="__('Allow users to make copies of your repository to a new project')"
        >
          <project-feature-setting
            v-model="forkingAccessLevel"
            :options="forkingLevelOptions"
            :disabled-input="!repositoryEnabled"
            name="project[project_setting][forking_access_level]"
          />
        </project-setting-row>
        <project-setting-row
          v-if="registryAvailable"
          :help-path="registryHelpPath"
          :label="__('Container registry')"
          :help-text="__('Every project can have its own space to store its Docker images')"
        >
          <project-feature-toggle
            v-model="containerRegistryEnabled"
            :disabled-input="!repositoryEnabled"
            name="project[container_registry_enabled]"
          />
        </project-setting-row>
        <project-setting-row
          v-if="lfsAvailable"
          :help-path="lfsHelpPath"
          :label="__('Git Large File Storage')"
          :help-text="__('Manages large files such as audio, video, and graphics files')"
        >
          <project-feature-toggle
            v-model="lfsEnabled"
            :disabled-input="!repositoryEnabled"
            name="project[lfs_enabled]"
          />
        </project-setting-row>
      </div>
      <project-setting-row :label="__('Wiki')" :help-text="__('Pages for project documentation')">
        <project-feature-setting
          v-model="wikiAccessLevel"
          :options="featureAccessLevelOptions"
          name="project[project_feature_attributes][wiki_access_level]"
        />
      </project-setting-row>
      <project-setting-row
        :label="__('Snippets')"
        :help-text="__('Share code pastes with others out of Git repository')"
      >
        <project-feature-setting
          v-model="snippetsAccessLevel"
          :options="featureAccessLevelOptions"
          name="project[project_feature_attributes][snippets_access_level]"
        />
      </project-setting-row>
      <project-setting-row
        v-if="pagesAvailable && pagesAccessControlEnabled"
        :help-path="pagesHelpPath"
        :label="__('Pages access control')"
        :help-text="__('Access control for the project\'s static website')"
      >
        <project-feature-setting
          v-model="pagesAccessLevel"
          :options="pagesFeatureAccessLevelOptions"
          name="project[project_feature_attributes][pages_access_level]"
        />
      </project-setting-row>
    </div>
  </div>
</template>
