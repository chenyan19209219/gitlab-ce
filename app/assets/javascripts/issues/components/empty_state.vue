<script>
import { GlEmptyState } from '@gitlab/ui';
import { imagePath } from '~/lib/utils/common_utils';
import { ISSUE_STATES } from '../constants';

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
      ISSUE_STATES,
    };
  },
  computed: {
    showFilterEmptyState() {
      const { hasFilters, state } = this;
      return hasFilters && ![ISSUE_STATES.OPENED, ISSUE_STATES.CLOSED].includes(state);
    },
  },
};
</script>

<template>
  <gl-empty-state
    v-if="showFilterEmptyState"
    :title="__('Sorry, your filter produced no results')"
    :description="__('To widen your search, change or remove filters above')"
    :svg-path="imagePath"
  />
  <gl-empty-state
    v-else-if="state === ISSUE_STATES.OPENED"
    :title="__('There are no open issues')"
    :description="__('To keep this project going, create a new issue')"
    :primary-button-link="buttonPath"
    :primary-button-text="__('New issue')"
    :svg-path="imagePath"
  />
  <gl-empty-state
    v-else-if="state === ISSUE_STATES.CLOSED"
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
