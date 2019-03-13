<script>
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import Icon from '~/vue_shared/components/icon.vue';
import ProjectAvatar from './project_avatar.vue';
import ProjectCounts from './project_counts.vue';
import ProjectMetadataInfo from './project_metadata_info.vue';
import ProjectTitle from './project_title.vue';

/**
 * Renders a project list item
 */
export default {
  components: {
    Icon,
    TimeAgoTooltip,
    ProjectAvatar,
    ProjectCounts,
    ProjectMetadataInfo,
    ProjectTitle,
  },
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
  computed: {
    project_path() {
      return `/${this.project.path_with_namespace}`;
    },
    avatarSizeClass() {
      return `s${this.size}`;
    },
    merge_requests_count: () => 0,
    issues_count: () => 0,
    hasDescription() {
      return this.project && this.project.description;
    },
    classes() {
      const base = 'd-flex project-row';
      return this.hasDescription ? base : `${base} no-description`;
    },
    totals() {
      return {
        forksCount: this.project.forks_count || 0,
        issuesCount: this.project.open_issues_count || 0,
        starCount: this.project.star_count || 0,
        mergeRequestsCount: this.project.merge_requests_count || 0,
      };
    },
  },
};
</script>
<template v-if="project">
  <!-- TODO: replace placeholder content -->
  <li :class="classes">
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
        <project-counts
          :archived="project.archived"
          :project-path="project_path"
          :star-count="totals.starCount"
          :issues-count="totals.issuesCount"
          :forks-count="totals.forksCount"
          :merge-requests-count="totals.mergeRequestsCount"
        />
        <div class="updated-note">
          <span>Updated
            <time-ago-tooltip :time="project.last_activity_at"/>
          </span>
        </div>
      </div>
    </div>
  </li>
</template>
