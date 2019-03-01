<script>
import { GlTooltipDirective } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import TimeAgoTooltip from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    issues: {
      type: Array,
      required: true,
    }
  }
}
</script>
<template>
  <ul class="content-list issues-list issuable-list">
    <li v-for="issue in issues" :key="issue.id" :id="issues.id" :data-url="issue">
      <div class="issue-box">
        <div class="issuable-info-container">
          <div class="issuable-main-info">
            <div class="issue-title title">
              <span class="issue-title-text">
                <span
                  v-if="issue.confidential"
                  v-gl-tooltip
                  class="has-tooltip" 
                  :title="__('Confidential')" 
                  :aria-label="__('Confidential')">
                  <Icon name="eye-slash"/>
                </span>
                <a href="#">{{issue.title}}</a>
                <span 
                  v-if="issue.tasks"
                  class="task-status d-none d-sm-inline-block">
                    &nbsp;
                    {{issue.task_status}}
                </span>
              </span>
            </div>
            <div class="issuable-info">
              <span class="issuable-reference"></span>
              <span class="issuable-authored d-none d-sm-inline-block">
                &middot;
              </span>
              <span class="issuable-milestone d-none d-sm-inline-block">
                
              </span>
            </div>
          </div>
        </div>
      </div>
    </li>
  </ul>
</template>

