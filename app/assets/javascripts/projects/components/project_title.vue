<script>
export default {
  props: {
    projectNamespace: {
      type: String,
      required: true,
    },
    projectName: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <h2 class="d-flex prepend-top-8">
    <a class="text-plain" :href="projectPath">
      <span class="project-full-name append-right-8">
        <span class="namespace-name">{{projectNamespace}} /</span>
        <span class="project-name">{{projectName}}</span>
      </span>
    </a>
  </h2>
</template>
