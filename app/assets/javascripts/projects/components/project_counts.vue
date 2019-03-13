<script>
import Icon from '~/vue_shared/components/icon.vue';

/**
 * Renders a project list item
 */
export default {
  components: {
    Icon,
  },
  props: {
    archived: {
      type: Boolean,
      default: false,
    },
    starCount: {
      type: Number,
      required: true,
    },
    forksCount: {
      type: Number,
      required: true,
    },
    issuesCount: {
      type: Number,
      required: true,
    },
    mergeRequestsCount: {
      type: Number,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return { baseClasses: 'align-items-center icon-wrapper has-tooltip' };
  },
  computed: {
    items() {
      return [
        {
          slug: null,
          title: 'Stars',
          total: this.starCount,
          icon: 'star',
          class: 'd-flex stars',
        },
        {
          slug: 'forks',
          title: 'Forks',
          total: this.forksCount,
          icon: 'fork',
          class: 'forks',
        },
        {
          slug: 'issues',
          title: 'Issues',
          total: this.issuesCount,
          icon: 'issues',
          class: 'd-none d-xl-flex  issues',
        },
        {
          slug: 'merge_requests',
          title: 'Merge requests',
          total: this.mergeRequestsCount,
          icon: 'git-merge',
          class: 'd-none d-xl-flex  merge-requests',
        },
      ];
    },
  },
};
</script>
<template>
  <div class="icon-container d-flex align-items-center">
    <span v-if="archived" class="d-flex icon-wrapper badge badge-warning">archived</span>
    <!-- TODO: re-usable -->
    <template v-for="i in items">
      <a
        v-if="i.slug"
        :key="`project-count-${i.title}`"
        :class="[baseClasses, i.class]"
        :title="i.title"
        :href="`${projectPath}/${i.slug}`"
        data-container="body"
        data-placement="top"
      >
        <icon :name="i.icon" :size="14" css-classes="append-right-4"/>
        {{i.total}}
      </a>
      <span
        v-else
        :key="`project-count-${i.title}`"
        :class="[baseClasses, i.class]"
        :title="i.title"
        data-container="body"
        data-placement="top"
      >
        <icon :name="i.icon" :size="14" css-classes="append-right-4"/>
        {{i.total}}
      </span>
    </template>
  </div>
</template>
