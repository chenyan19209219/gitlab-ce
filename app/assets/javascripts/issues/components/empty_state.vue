<script>
import { GlEmptyState } from '@gitlab/ui';
import { imagePath } from '~/lib/utils/common_utils';

export default {
  components: {
    GlEmptyState,
  },
  props: {
    hasFilters: {
      type: Boolean,
      required: true,
    },
    state: {
      type: String,
      required: true,
    },
    buttonPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      imagePath: imagePath('illustrations/issues.svg'),
    };
  },
};
</script>

<template>
  <gl-empty-state
    v-if="hasFilters"
    :title="__('Sorry, your filter produced no results')"
    :description="__('To widen your search, change or remove filters above')"
    :svg-path="imagePath"
  />
  <gl-empty-state
    v-else-if="state === 'opened'"
    :title="__('There are no open issues')"
    :description="__('To keep this project going, create a new issue')"
    :primary-button-link="buttonPath"
    :primary-button-text="__('New issue')"
    :svg-path="imagePath"
  />
  <gl-empty-state
    v-else-if="state === 'closed'"
    :title="__('There are no closed issues')"
    :svg-path="imagePath"
  />
  <gl-empty-state
    v-else
    :title="__('There are no issues to show')"
    :description="
      __(
        'The Issue Tracker is the place to add things that need to be improved or solved in a project. You can register or sign in to create issues for this project.',
      )
    "
    :svg-path="imagePath"
  />
</template>
