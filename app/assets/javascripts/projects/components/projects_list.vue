<script>
import Api from '~/api';
import ProjectDetail from './project_detail.vue';
import ProjectAvatar from './project_avatar.vue';

const fetchProjects = () => Api.projects();

/**
 * Renders a list of projects
 */
export default {
  data: () => ({
    projects: [],
  }),
  created() {
    fetchProjects().then(res => {
      console.log('projects_list::created::fetchProjects::res', res);
      this.projects = res;
    });
  },
  methods: {},
  components: {
    ProjectDetail,
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
        <project-avatar :project="project"></project-avatar>
        <project-detail :project="project"></project-detail>
      </li>
    </ul>
  </div>
</template>
