<script>
import Api from '~/api';
import ProjectListItem from './project_list_item.vue';

const fetchProjects = (q = '') => Api.projects(q, { simple: false, order_by: 'last_activity_at' });

/**
 * Renders a list of projects
 */

export default {
  components: {
    ProjectListItem,
  },
  props: {},
  data() {
    // TODO: add type definitions
    return {
      projects: [],
      size: 48,
    };
  },
  computed: {},
  created() {
    fetchProjects().then(res => {
      console.log('projects_list::created::fetchProjects::res', res);
      console.log(res[0]);
      this.projects = res;
    });
  },
  methods: {},
};
</script>
<template>
  <div>
    <!-- TODO: loading spinner -->
    <!-- TODO: empty project state -->
    <ul class="projects-list">
      <template v-for="project in projects">
        <project-list-item :key="project.id" :project="project"/>
      </template>
    </ul>
  </div>
</template>
