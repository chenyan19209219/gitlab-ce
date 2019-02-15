<script>
import Api from '~/api';
import ProjectListItem from './project_list_item.vue';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';

const fetchProjects = () => Api.projects();

/**
 * Renders a list of projects
 */
export default {
  data: () => ({
    // TODO: add type definitions
    projects: [],
    projectAvatarSize: 48,
  }),
  created() {
    fetchProjects().then(res => {
      console.log('projects_list::created::fetchProjects::res', res);
      this.projects = res;
    });
  },
  methods: {},
  components: {
    ProjectListItem,
    ProjectAvatar,
  },
  props: {},
  computed: {},
};
</script>
<template>
  <div>
    <!-- TODO: loading spinner -->
    <!-- TODO: empty project state -->
    <ul class="projects-list">
      <li class="d-flex project-row" v-for="project in projects" :key="project.id">
        <project-avatar
          :project="project"
          class="flex-grow-0 flex-shrink-0"
          :size="projectAvatarSize"
        />
        <project-list-item :project="project"/>
      </li>
    </ul>
  </div>
</template>
