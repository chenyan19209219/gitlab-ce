<script>
import Api from '~/api';
import ProjectListItem from './project_list_item.vue';

const fetchProjects = (q = '') => Api.projects(q, { simple: false });

/**
 * Renders a list of projects
 */

export default {
  data: function() {
    // TODO: add type definitions
    return {
      projects: [],
      size: 48,
    };
  },
  created() {
    fetchProjects().then(res => {
      console.log('projects_list::created::fetchProjects::res', res);
      console.log(res[0]);
      this.projects = res;
    });
  },
  methods: {},
  components: {
    ProjectListItem,
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
      <template v-for="project in projects">
        <project-list-item :project="project" :key="project.id"/>
      </template>
    </ul>
  </div>
</template>
