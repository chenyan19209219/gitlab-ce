# frozen_string_literal: true

require_relative 'kubernetes_helpers'

module ClustersHelpers
  include KubernetesHelpers

  def stub_gitlab_kubernetes_calls(api_url:, platform_token: 'gitlab-token')
    stub_api_base_calls(api_url)
    stub_gitlab_resources_calls(api_url, platform_token)
  end

  def stub_clusterable_kubernetes_calls(api_url:, namespace:, service_account:, secret_name:, token: 'sample-token')
    stub_gitlab_kubernetes_calls(api_url: api_url)
    stub_clusterable_resources_calls(api_url, namespace, service_account, secret_name, token)
  end

  private

  def stub_api_base_calls(api_url)
    stub_kubeclient_discover(api_url)
    stub_kubeclient_get_namespace(api_url)
    stub_kubeclient_create_namespace(api_url)
    stub_kubeclient_create_service_account(api_url)
    stub_kubeclient_create_secret(api_url)
  end

  def stub_gitlab_resources_calls(api_url, platform_token)
    stub_kubeclient_get_service_account_error(api_url, Clusters::Gcp::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAME)
    stub_kubeclient_get_secret(
      api_url,
      {
        metadata_name: Clusters::Gcp::Kubernetes::GITLAB_ADMIN_TOKEN_NAME,
        token: Base64.encode64(platform_token)
      }
    )
    stub_kubeclient_get_secret_error(api_url, platform_token)
    stub_kubeclient_put_secret(api_url, Clusters::Gcp::Kubernetes::GITLAB_ADMIN_TOKEN_NAME)

    # Needed for RBAC clusters
    stub_kubeclient_get_cluster_role_binding_error(api_url, Clusters::Gcp::Kubernetes::GITLAB_CLUSTER_ROLE_BINDING_NAME)
    stub_kubeclient_create_cluster_role_binding(api_url)
  end

  def stub_clusterable_resources_calls(api_url, namespace, service_account, secret_name, token)
    stub_kubeclient_get_namespace(api_url, namespace: namespace)
    stub_kubeclient_get_service_account_error(api_url, service_account, namespace: namespace)
    stub_kubeclient_create_service_account(api_url, namespace: namespace)
    stub_kubeclient_get_role_binding(api_url, "gitlab-#{namespace}", namespace: namespace)
    stub_kubeclient_put_role_binding(api_url, "gitlab-#{namespace}", namespace: namespace)
    stub_kubeclient_create_secret(api_url, namespace: namespace)

    stub_kubeclient_get_secret(
      api_url,
      {
        metadata_name: secret_name,
        token: Base64.encode64(token),
        namespace: namespace
      }
    )

    stub_kubeclient_put_secret(api_url, secret_name, namespace: namespace)

    # Needed for RBAC clusters
    stub_kubeclient_get_role_binding_error(api_url, "gitlab-#{namespace}", namespace: namespace)
    stub_kubeclient_create_role_binding(api_url, namespace: namespace)
  end
end
