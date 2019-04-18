<script>
export default {
  props: {
    isExploreProjectsTab: {
      type: Boolean,
      default: false,
    },
    accessLevel: {
      type: Number, // TODO: double check
      required: true,
      default: 0,
    },
    humanAccess: {
      type: String, // TODO: double check
      required: true,
      default: '',
    },
  },
  computed: {
    showAccessLevel: function() {
      return !this.isExploreProjectsTab && this.accessLevel > 0 && this.humanAccess ? true : false;
    },
  },
};
</script>
<template>
  <div v-if="showAccessLevel" class="metadata-info prepend-top-8">
    <span class="user-access-role d-block">{{humanAccess}}</span>
  </div>
</template>
