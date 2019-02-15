<script>
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import Icon from '~/vue_shared/components/icon.vue';
import ProjectAvatar from './project_avatar.vue';
import ProjectMetadataInfo from './project_metadata_info.vue';
import ProjectTitle from './project_title.vue';

/**
 * Renders a project list item
 */
export default {
  props: {
    project: {
      id: {
        type: Number,
        required: true,
      },
      name: {
        type: String,
        required: true,
      },
      description: {
        type: String,
        required: true,
      },
      name_with_namespace: {
        type: String,
        required: true,
      },
      path: {
        type: String,
        required: true,
      },
      path_with_namespace: {
        type: String,
        required: true,
      },
      created_at: {
        type: String,
        required: true,
      },
      default_branch: {
        type: String,
        required: true,
      },
      ssh_url_to_repo: {
        type: String,
        required: true,
      },
      http_url_to_repo: {
        type: String,
        required: true,
      },
      web_url: {
        type: String,
        required: true,
      },
      readme_url: {
        type: String,
        required: true,
      },
      avatar_url: {
        type: String,
        required: true,
      },
      star_count: {
        type: Number,
        required: true,
      },
      forks_count: {
        type: Number,
        required: true,
      },
      open_issues_count: {
        type: Number,
        required: true,
      },

      // TODO: Currently returned from the API, but not the same value as last_activity_date
      last_activity_at: {
        type: String,
        required: true,
      },
      last_activity_date: {
        type: String,
        required: true,
      },
      namespace: {
        id: {
          type: Number,
          required: true,
        },
        name: {
          type: String,
          required: true,
        },
        path: {
          type: String,
          required: true,
        },
        kind: {
          type: String,
          required: true,
        },
        full_path: {
          type: String,
          required: true,
        },
      },
    },
  },
  components: {
    Icon,
    TimeAgoTooltip,
    ProjectAvatar,
    ProjectMetadataInfo,
    ProjectTitle,
  },
  computed: {
    project_path: function() {
      return `/${this.project.path_with_namespace}`;
    },
    avatarSizeClass() {
      return `s${this.size}`;
    },
    merge_requests_count: () => 0,
    issues_count: () => 0,
    hasDescription: function() {
      return this.project && this.project.description;
    },
  },
};
</script>
<template v-if="project">
  <!-- TODO: replace placeholder content -->
  <li class="d-flex project-row">
    <project-avatar :project="project"/>
    <div class="project-details d-sm-flex flex-sm-fill align-items-center">
      <div class="flex-wrapper">
        <div class="d-flex align-items-center flex-wrap project-title">
          <project-title
            :project-name="project.name"
            :project-path="project_path"
            :project-namespace="project.namespace.name"
          />
          <project-metadata-info/>
        </div>
        <div v-if="hasDescription" class="description d-none d-sm-block append-right-default">
          <p data-sourcepos="1:1-1:57" dir="auto">{{project.description}}</p>
        </div>
      </div>
      <div
        class="align-items-center align-items-sm-end controls d-flex flex-lg-row flex-shrink-0 flex-sm-column flex-wrap justify-content-lg-between"
      >
        <!-- TODO: re-usable -->
        <div class="icon-container d-flex align-items-center">
          <span
            class="d-flex align-items-center icon-wrapper stars has-tooltip"
            data-container="body"
            data-placement="top"
            title="Stars"
          >
            <icon name="star" :size="14" css-classes="append-right-4"/>
            {{project.star_count}}
          </span>
          <!-- TODO: re-usable -->
          <a
            class="align-items-center icon-wrapper forks has-tooltip"
            title="Forks"
            data-container="body"
            data-placement="top"
            :href="`${project_path}/forks`"
          >
            <icon name="fork" :size="14" css-classes="append-right-4"/>
            {{project.forks_count}}
          </a>
          <a
            class="d-none d-xl-flex align-items-center icon-wrapper merge-requests has-tooltip"
            title="Merge Requests"
            data-container="body"
            data-placement="top"
            :href="`${project_path}/merge_requests`"
          >
            <icon name="git-merge" :size="14" css-classes="append-right-4"/>
            {{merge_requests_count}}
          </a>
          <a
            class="d-none d-xl-flex align-items-center icon-wrapper issues has-tooltip"
            title="Issues"
            data-container="body"
            data-placement="top"
            :href="`${project_path}/issues`"
          >
            <icon name="issues" :size="14" css-classes="append-right-4"/>
            {{project.open_issues_count}}
          </a>
        </div>
        <div class="updated-note">
          <span>Updated
            <time-ago-tooltip :time="project.last_activity_at"/>
          </span>
        </div>
      </div>
    </div>
  </li>
</template>
