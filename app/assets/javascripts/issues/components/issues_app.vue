<script>
import dateFormat from 'dateformat';
import { GlTooltipDirective } from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import Icon from '~/vue_shared/components/icon.vue';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { getDayDifference } from '~/lib/utils/datetime_utility';
import { getParameterValues } from '~/lib/utils/url_utility';

export default {
  components: {
    Icon,
    UserAvatarLink,
    TimeAgoTooltip,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    canBulkUpdate: {
      type: Boolean,
      required: true,
    }
  },
  data() {
    return {
      maxRender: 4,
      maxCounter: 99,
    };
  },
  computed: {
    ...mapState('issuesList', ['issues', 'loading', 'isBulkUpdating']),
    ...mapGetters('issuesList', ['hasFilters', 'appliedFilters']),
  },
  watch: {
    appliedFilters() {
      this.fetchIssues(this.endpoint);
      this.updateIssueStateTabs();
    },
  },
  mounted() {
    this.fetchIssues(this.endpoint);
    this.updateIssueStateTabs();
  },
  methods: {
    ...mapActions('issuesList', ['fetchIssues']),
    issueClasses(issue) {
      const classList = ['issue'];
      const issueCreatedToday = !getDayDifference(new Date(issue.created_at), new Date());

      if (issue.state === 'closed') {
        classList.push('closed');
      }

      if (issueCreatedToday) {
        classList.push('today');
      }

      return classList.join(' ');
    },
    formatDueDate(dueDate) {
      return dateFormat(dueDate, 'mmm d, yyyy');
    },
    isIssueOverDue(dueDate) {
      return getDayDifference(new Date(), new Date(dueDate)) < 0;
    },
    labelStyle(label) {
      return {
        backgroundColor: label.color,
        color: label.textColor,
      };
    },
    shouldRenderAssignee(currentIndex) {
      return currentIndex < this.maxRender;
    },
    getAvatarTitle(assignee) {
      return `Assigned to ${assignee.name}`;
    },
    shouldAssigneeRenderCounter(assignees) {
      return assignees.length - this.maxRender > 0;
    },
    moreAssigneesCount(assignees) {
      return assignees.length - this.maxRender;
    },
    assigneeCounterTooltip(assignees) {
      return `+${this.moreAssigneesCount(assignees)} more assignees`;
    },
    issueCommentsURL(issue) {
      return `${issue.web_url}#notes`;
    },
    updateIssueStateTabs() {
      const [ state ] = getParameterValues('state');
      const activeTabEl = document.querySelector('.issues-state-filters .active');

      if (activeTabEl && !activeTabEl.querySelector(`[data-state="${state}"]`)) {
        const newActiveTabEl = document.querySelector(`.issues-state-filters [data-state="${state}"]`);

        activeTabEl.classList.remove('active');
        newActiveTabEl.parentElement.classList.add('active');
      }
    },
    bulkUpdateId(id) {
      return `selected_issue_${id}`;
    },
  },
};
</script>
<template>
  <ul v-if="issues" class="content-list issues-list issuable-list">
    <li
      v-for="issue in issues"
      :id="issues.id"
      :key="issue.id"
      :url="issue.web_url"
      :class="issueClasses(issue)"
    >
      <div class="issue-box">
        <div 
          v-if="canBulkUpdate"
          class="issue-check"
          :class="{hidden: !isBulkUpdating}"
        >
          <input
            type="checkbox" 
            class="selected-issuable"
            :id="bulkUpdateId(issue.id)" 
            :name="bulkUpdateId(issue.id)"
            :data-id="issue.id"
          />
        </div>
        <div class="issuable-info-container">
          <div class="issuable-main-info">
            <div class="issue-title title">
              <span class="issue-title-text">
                <span
                  v-if="issue.confidential"
                  v-gl-tooltip
                  class="has-tooltip"
                  :title="__('Confidential')"
                  :aria-label="__('Confidential')"
                >
                  <Icon name="eye-slash" class="align-text-bottom" />
                </span>
                <a :href="issue.web_url">{{ issue.title }}</a>
                <span v-if="issue.tasks" class="task-status d-none d-sm-inline-block">
                  &nbsp;
                  {{ issue.task_status }}
                </span>
              </span>
            </div>
            <div class="issuable-info">
              <span class="issuable-reference">{{ issue.reference_path }}</span>
              <span class="issuable-authored d-none d-sm-inline-block">
                &middot; opened
                <time-ago-tooltip :time="issue.created_at" tooltip-placement="bottom" />
                by
                <a
                  class="author-link js-user-link"
                  :data-user-id="issue.author.id"
                  :data-username="issue.author.username"
                  :data-name="issue.author.name"
                  :href="issue.author.web_url"
                >
                  <span class="author">{{ issue.author.name }}</span>
                </a>
              </span>
              <span v-if="issue.milestone" class="issuable-milestone d-none d-sm-inline-block">
                &nbsp;
                <a :href="issue.milestone.web_url">
                  <icon name="clock" class="align-text-bottom" />
                  {{ issue.milestone.title }}
                </a>
              </span>
              <span
                v-if="issue.due_date"
                v-gl-tooltip
                class="issuable-due-date d-none d-sm-inline-block has-tooltip"
                :title="__('Due date')"
                :class="{ cred: isIssueOverDue(issue.due_date) }"
              >
                &nbsp;
                <icon name="calendar" class="align-text-bottom" />
                {{ formatDueDate(issue.due_date) }}
              </span>
              <span v-if="issue.labels.length">
                &nbsp;
                <a
                  v-for="label in issue.labels"
                  :key="label.id"
                  class="label-link"
                  :href="label.web_url"
                >
                  <span
                    v-gl-tooltip
                    class="badge color-label has-tooltip"
                    :style="labelStyle(label)"
                    :title="label.description"
                  >
                    {{ label.title }}
                  </span>
                </a>
              </span>
            </div>
          </div>
          <div class="issuable-meta">
            <ul class="controls">
              <li v-if="issue.state === 'closed'" class="issuable-status">CLOSED</li>
              <li v-if="issue.assignees.length">
                <user-avatar-link
                  v-for="(assignee, index) in issue.assignees"
                  v-if="shouldRenderAssignee(index)"
                  :key="assignee.id"
                  :link-href="assignee.web_url"
                  :img-alt="getAvatarTitle(assignee)"
                  :img-src="assignee.avatar_url"
                  :img-size="16"
                  :tooltip-text="getAvatarTitle(assignee)"
                  tooltip-placement="bottom"
                />
                <span
                  v-if="shouldAssigneeRenderCounter(issue.assignees)"
                  v-gl-tooltip
                  :title="assigneeCounterTooltip(issue.assignees)"
                  class="avatar-counter has-tooltip"
                  data-placement="bottom"
                >
                  +{{ moreAssigneesCount(issue.assignees) }}
                </span>
              </li>
              <li
                v-if="issue.merge_requests_count > 0"
                class="issuable-mr d-none d-sm-block has-tooltip"
                :title="__('Related merge requests')"
              >
                <icon name="merge-request" class="align-text-bottom icon-merge-request-unmerged" />
                {{ issue.merge_requests_count }}
              </li>

              <li
                v-if="issue.upvotes > 0"
                class="issuable-upvotes d-none d-sm-block has-tooltip"
                :title="__('Upvotes')"
              >
                <icon name="thumb-up" class="align-text-bottom" />
                {{ issue.upvotes }}
              </li>

              <li
                v-if="issue.downvotes > 0"
                class="issuable-downvotes d-none d-sm-block has-tooltip"
                :title="__('Upvotes')"
              >
                <icon name="thumb-down" class="align-text-bottom" />
                {{ issue.downvotes }}
              </li>

              <li class="issuable-comments d-none d-sm-block">
                <a
                  class="has-tooltip"
                  :href="issueCommentsURL(issue)"
                  :class="{ 'no-comments': issue.note_count < 0 }"
                  :title="__('Comments')"
                >
                  <icon name="comments" class="align-text-bottom" />
                  {{ issue.note_count || 0 }}
                </a>
              </li>
            </ul>
            <div class="float-right issuable-updated-at d-none d-sm-inline-block">
              <span>
                updated
                <time-ago-tooltip
                  :time="issue.updated_at"
                  tooltip-placement="bottom"
                  css-class="issue_update_ago"
                />
              </span>
            </div>
          </div>
        </div>
      </div>
    </li>
  </ul>
</template>
