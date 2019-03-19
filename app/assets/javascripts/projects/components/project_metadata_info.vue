<script>
export default {
  props: {
    isExplore: {
      type: Boolean,
      default: false,
    },
    accessLevel: {
      type: Number, // TODO: double check
      default: 0,
    },
    humanAccess: {
      type: String, // TODO: double check
      default: '',
    },
  },
};
</script>
<template>
  <div>
    <span if="accessLevel" class="user-access-role d-block">{{humanAccess}}</span>
    <div class="metadata-info prepend-top-8">
      <span class="user-access-role d-block">Developer</span>
    </div>
  </div>
</template>
