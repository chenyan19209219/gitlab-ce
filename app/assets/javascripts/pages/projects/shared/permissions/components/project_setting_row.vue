<script>
import { GlLink, GlPopover } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    GlLink,
    Icon,
    GlPopover,
  },
  props: {
    label: {
      type: String,
      required: false,
      default: null,
    },
    helpPath: {
      type: String,
      required: false,
      default: null,
    },
    helpText: {
      type: String,
      required: false,
      default: null,
    },
    helpTooltipText: {
      type: String,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <div class="project-feature-row">
    <label v-if="label" class="label-bold">
      {{ label }}
      <gl-link v-if="helpPath" :href="helpPath" target="_blank">
        <icon :size="14" name="question" aria-hidden="true" data-hidden="true" />
      </gl-link>
      <template v-if="helpTooltipText">
        <gl-link id="help-popup-trigger" href="#">
          <icon :size="14" name="question" />
        </gl-link>
        <gl-popover
          target="help-popup-trigger"
          boundary="viewport"
          placement="top"
          triggers="hover"
        >
          {{ helpTooltipText }}
        </gl-popover>
      </template>
    </label>
    <span v-if="helpText" class="form-text text-muted"> {{ helpText }} </span> <slot></slot>
  </div>
</template>
