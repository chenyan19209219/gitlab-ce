<script>
import { mapActions, mapState } from 'vuex';
import { GlLoadingIcon, GlButton } from '@gitlab/ui';
import createStore from '../store';

export default {
  name: 'PagesDomainApp',
  store: createStore(),
  components: {
    GlLoadingIcon,
    GlButton,
  },
  props: {
    domainEndpoint: {
      type: String,
      required: true,
    },
    domainName: {
      type: String,
      required: true,
    },

    // TODO: this property be passed through the API
    // with the rest of the domain info once
    // the field has been exposed
    domainKey: {
      type: String,
      required: true,
    },
  },
  created() {
    // TODO: figure out the correct endpoint to use
    // this.setDomainEndpoint(this.domainEndpoint);
    this.setDomainEndpoint('/api/v4/projects/24/pages/domains/my-domain.example.com');

    this.setDomainName(this.domainName);
  },
  mounted() {
    this.fetchDomain();
  },
  computed: {
    ...mapState(['isLoading', 'domain']),

    shouldRenderContent() {
      return !this.isLoading && !this.hasError;
    },
  },
  methods: {
    ...mapActions(['setDomainEndpoint', 'setDomainName', 'fetchDomain']),
  },
};
</script>

<template>
  <div>
    <h3 class="page-title">{{ domainName }}</h3>
    <hr />

    <gl-loading-icon
      v-if="isLoading"
      :size="2"
      class="js-job-loading qa-loading-animation prepend-top-20"
    />

    <div v-if="shouldRenderContent" class="form">
      <div class="form-group row">
        <label for="pages_domain_domain" class="col-form-label col-sm-2">Domain</label>
        <div class="col-sm-10">
          <input
            v-model="domain.domain"
            type="text"
            class="form-control"
            required="required"
            autocomplete="off"
            disabled="disabled"
            name="pages_domain[domain]"
            id="pages_domain_domain"
          />
        </div>
      </div>
      <div class="form-group row">
        <label for="pages_domain_certificate" class="col-form-label col-sm-2"
          >Certificate (PEM)</label
        >
        <div class="col-sm-10">
          <textarea
            v-model="domain.certificate.certificate"
            rows="5"
            class="form-control"
            name="pages_domain[certificate]"
            id="pages_domain_certificate"
          />
          <span class="help-inline">
            Upload a certificate for your domain with all intermediates
          </span>
        </div>
      </div>
      <div class="form-group row">
        <label for="pages_domain_key" class="col-form-label col-sm-2">Key (PEM)</label>
        <div class="col-sm-10">
          <textarea
            v-model="domainKey"
            rows="5"
            class="form-control"
            name="pages_domain[key]"
            id="pages_domain_key"
          />
          <span class="help-inline">
            Upload a private key for your certificate
          </span>
        </div>
      </div>
      <div class="form-actions">
        <gl-button name="commit" variant="success">Save Changes</gl-button>
      </div>
    </div>
  </div>
</template>
