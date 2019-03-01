<script>
import Icon from '~/vue_shared/components/icon.vue';

export default {
  components: {
    Icon,
  },
  props: {
    variable: {
      type: Object,
      required: true,
    },
    valueVisible: {
      type: Boolean,
      required: true,
    },
    setModalVariable: {
      type: Function,
      required: true,
    },
  },
};
</script>

<template>
  <div class="gl-responsive-table-row">
    <div class="table-section section-25">
      <div role="rowheader" class="table-mobile-header">{{ s__('Variables|Key') }}</div>
      <div class="table-mobile-content">
        <div class="key">{{ variable.key }}</div>
      </div>
    </div>
    <div class="table-section section-25">
      <div role="rowheader" class="table-mobile-header">{{ s__('Variables|Value') }}</div>
      <div class="table-mobile-content">
        <div class="value">{{ valueVisible ? variable.value : '**********' }}</div>
      </div>
    </div>
    <div class="table-section section-15">
      <div role="rowheader" class="table-mobile-header">{{ s__('Variables|Protected') }}</div>
      <div class="table-mobile-content">
        <div class="protected">{{ variable.protected ? 'Yes' : 'No' }}</div>
      </div>
    </div>
    <div class="table-section section-15">
      <div role="rowheader" class="table-mobile-header">{{ s__('Variables|Masked') }}</div>
      <div class="table-mobile-content">
        <div class="masked">{{ variable.masked ? 'Yes' : 'No' }}</div>
      </div>
    </div>
    <div class="table-section section-20 table-button-footer deploy-key-actions">
      <div class="table-action-buttons">
        <button
          class="btn btn-default"
          type="button"
          data-target="#edit-variable-modal"
          data-toggle="modal"
          @click="setModalVariable(variable)"
        >
          <icon :size="16" :aria-label="__('Edit')" name="pencil" />
        </button>
        <button
          class="btn btn-danger btn-inverted"
          type="button"
          data-target="#delete-variable-modal"
          data-toggle="modal"
          @click="setModalVariable(variable)"
        >
          <icon :size="16" :aria-label="__('Delete')" name="remove" />
        </button>
      </div>
    </div>
  </div>
</template>
