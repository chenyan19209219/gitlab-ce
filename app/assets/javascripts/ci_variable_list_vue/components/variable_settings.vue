<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import GlModal from '~/vue_shared/components/gl_modal.vue';
import { GlLoadingIcon } from '@gitlab/ui';
import store from '../store';
import VariablesTable from './variables_table.vue';
import VariableForm from './variable_form.vue';

export default {
  store,
  components: {
    VariablesTable,
    VariableForm,
    GlLoadingIcon,
    GlModal,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['hasVariables']),
    ...mapState(['variables', 'valuesVisible', 'isLoading', 'modalVariable']),
  },
  created() {
    this.setEndpoint(this.endpoint);
  },
  mounted() {
    this.fetchVariables();
  },
  methods: {
    ...mapActions([
      'setEndpoint',
      'fetchVariables',
      'toggleValuesVisibility',
      'setModalVariable',
      'updateModalVariable',
      'addVariable',
      'updateVariable',
      'deleteVariable',
    ]),
  },
};
</script>

<template>
  <div class="variables-settings col-lg-12">
    <gl-modal
      id="add-variable-modal"
      :header-title-text="s__('Variables|Add variable')"
      :footer-primary-button-text="s__('Variables|Add variable')"
      footer-primary-button-variant="success"
      @submit="addVariable"
    >
      <variable-form :variable="modalVariable" :update-modal-variable="updateModalVariable" />
    </gl-modal>
    <gl-modal
      id="edit-variable-modal"
      :header-title-text="s__('Variables|Edit variable')"
      :footer-primary-button-text="s__('Variables|Save variable')"
      footer-primary-button-variant="success"
      @submit="updateVariable"
    >
      <variable-form :variable="modalVariable" :update-modal-variable="updateModalVariable" />
    </gl-modal>
    <gl-modal
      id="delete-variable-modal"
      :header-title-text="s__('Variables|Delete variable?')"
      :footer-primary-button-text="s__('Variables|Delete variable')"
      footer-primary-button-variant="danger"
      @submit="deleteVariable"
    >
      Are you sure you want to delete {{ modalVariable.key }}?
    </gl-modal>
    <div class="content-block">
      <gl-loading-icon
        v-if="isLoading && !hasVariables"
        :label="s__('Variables|Loading variables')"
        :size="2"
      />
      <template v-else-if="hasVariables">
        <h5>Variables</h5>
        <variables-table
          :values-visible="valuesVisible"
          :variables="variables"
          :endpoint="endpoint"
          :set-modal-variable="setModalVariable"
        />
      </template>
      <div class="controls prepend-top-default">
        <button
          type="button"
          class="btn prepend-top-default append-right-10 js-secret-value-reveal-button"
          @click="toggleValuesVisibility()"
        >
          {{ valuesVisible ? 'Hide values' : 'Reveal values' }}
        </button>
        <button
          type="button"
          class="btn btn-success btn-inverted prepend-top-default js-ci-variables-save-button"
          data-target="#add-variable-modal"
          data-toggle="modal"
          @click="setModalVariable({})"
        >
          Add variable
        </button>
      </div>
    </div>
  </div>
</template>
