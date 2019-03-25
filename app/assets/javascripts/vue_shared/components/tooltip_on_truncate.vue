<script>
import _ from 'underscore';
import { GlTooltipDirective } from '@gitlab/ui';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: '',
    },
    placement: {
      type: String,
      required: false,
      default: 'top',
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
    v-gl-tooltip="{ boundary: 'viewport', placement }"
    :title="title"
    :data-placement="placement"
    class="js-show-tooltip"
  >
    <slot></slot>
  </span>
  <span v-else> <slot></slot> </span>
</template>
