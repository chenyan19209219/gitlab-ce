<script>
export default {
  props: {
    variable: {
      type: Object,
      required: true,
    },
    updateModalVariable: {
      type: Function,
      required: true,
    },
    // helpPath: {
    //   type: String,
    //   required: false,
    //   default: '/help/ci/variables/README#masked-variables',
    // },
  },
  computed: {
    key: {
      get() {
        return this.variable.key ? this.variable.key : '';
      },
      set(key) {
        const variable = this.variable || {};
        this.updateModalVariable({
          ...variable,
          key,
        });
      },
    },
    value: {
      get() {
        return this.variable.value ? this.variable.value : '';
      },
      set(value) {
        const variable = this.variable || {};
        this.updateModalVariable({
          ...variable,
          value,
        });
      },
    },
    protectedFlag: {
      get() {
        return this.variable.protected ? this.variable.protected : '';
      },
      set(protectedFlag) {
        const variable = this.variable || {};
        this.updateModalVariable({
          ...variable,
          protected: protectedFlag,
        });
      },
    },
    maskedFlag: {
      get() {
        return this.variable.masked ? this.variable.masked : '';
      },
      set(masked) {
        const variable = this.variable || {};
        this.updateModalVariable({
          ...variable,
          masked,
        });
      },
    },
    warnAboutMaskability: {
      get() {
        // Eight or more alphanumeric characters plus underscores
        const regex = /^\w{8,}$/;
        const maskedChecked = this.variable.masked;
        const variableValue = this.variable.value;
        if (maskedChecked && !regex.test(variableValue)) return true;
        return false;
      },
    },
  },
};
</script>

<template>
  <div class="gl-show-field-errors">
    <div class="row">
      <div class="form-group col-md-6">
        <label for="variable-key" class="label-bold">{{ s__('Variables|Key') }}</label>
        <input id="variable-key" v-model="key" type="text" class="form-control" required />
      </div>
      <div class="form-group col-md-6">
        <label for="variable-value" class="label-bold">{{ s__('Variables|Value') }}</label>
        <input
          id="variable-value"
          v-model="value"
          type="text"
          :class="{
            'form-control': true,
            'gl-field-error-outline': warnAboutMaskability,
          }"
          required
        />
        <span v-if="warnAboutMaskability" class="gl-field-error">
          Cannot use Masked Variable with current value
          <a v-if="helpPath" :href="helpPath" target="_blank">
            <i aria-hidden="true" data-hidden="true" class="fa fa-question-circle"> </i>
          </a>
        </span>
      </div>
    </div>
    <div class="form-group">
      <label class="label-bold">{{ s__('Variables|Flags') }}</label>
      <fieldset>
        <label class="form-group">
          <input id="variable-protected" v-model="protectedFlag" type="checkbox" />
          {{ s__('Variables|Protect variable') }}
        </label>
      </fieldset>
      <fieldset>
        <label class="form-group">
          <input id="variable-masked" v-model="maskedFlag" type="checkbox" />
          {{ s__('Variables|Mask variable') }}
        </label>
      </fieldset>
    </div>
  </div>
</template>
