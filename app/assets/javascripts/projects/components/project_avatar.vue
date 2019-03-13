<script>
import ProjectAvatarImage from '~/vue_shared/components/project_avatar/image.vue';
import Identicon from '~/vue_shared/components/identicon.vue';

/**
 * Renders a project list item
 */
export default {
  components: {
    ProjectAvatarImage,
    Identicon,
  },
  props: {
    size: {
      type: Number,
      default: 48,
    },
    project: {
      id: {
        type: Number,
        required: true,
      },
      name: {
        type: String,
        required: true,
      },
      // TODO: camelcase
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
      avatar_url: {
        type: String,
        required: true,
      },
    },
  },
  computed: {
    project_path() {
      // TODO: should this be web_url?
      return `/${this.project.path_with_namespace}`;
    },
    sizeClass() {
      return `s${this.size}`;
    },
  },
};
</script>
<template>
  <div :class="sizeClass" class="avatar-container rect-avatar project-avatar">
    <a :href="project.path">
      <project-avatar-image
        v-if="project.avatar_url"
        :img-src="project.avatar_url"
        :img-alt="project.name"
        :img-size="size"
      />
      <identicon
        v-else
        :entity-id="project.id"
        :entity-name="project.name"
        :size-class="sizeClass"
        class="rect-avatar"
      />
    </a>
  </div>
</template>
