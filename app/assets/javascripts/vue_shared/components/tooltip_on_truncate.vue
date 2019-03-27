<script>
import _ from 'underscore';
import { GlTooltipDirective } from '@gitlab/ui';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    boundary: {
      type: String,
      required: false,
      default: 'viewport',
    },
    placement: {
      type: String,
      required: false,
      default: 'top',
    },
    title: {
      type: String,
      required: false,
      default: '',
    },
    truncateTarget: {
      type: [String, Function],
      required: false,
      default: '',
    },
  },
  data() {
    return {
      showTooltip: false,
    };
  },
  mounted() {
    const target = this.selectTarget();

    // NOTE: The secondary test allows for strings or spans to be passed
    // directly to this component
    if (
      target &&
      (target.scrollWidth > target.offsetWidth ||
        target.offsetWidth > target.parentElement.offsetWidth)
    ) {
      this.showTooltip = true;
    }
  },
  methods: {
    selectTarget() {
      if (_.isFunction(this.truncateTarget)) {
        return this.truncateTarget(this.$el);
      } else if (this.truncateTarget === 'child') {
        return this.$el.childNodes[0];
      }

      return this.$el;
    },
  },
};
</script>

<template>
  <span
    v-if="showTooltip"
    v-gl-tooltip="{ boundary, placement }"
    :title="title"
    class="js-show-tooltip"
  >
    <slot></slot>
  </span>
  <span v-else> <slot></slot> </span>
</template>
