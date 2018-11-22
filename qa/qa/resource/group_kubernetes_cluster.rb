# frozen_string_literal: true

require 'securerandom'

module QA
  module Resource
    class GroupKubernetesCluster < Base
      attr_writer :Group, :cluster,
        :install_helm_tiller, :install_ingress

      attribute :ingress_ip do
        Page::Group::Kubenertes::Kubernetes::Show.perform(&:ingress_ip)
      end

      def fabricate!
        @group.visit!

        Page::Group::Menu.perform(
          &:click_kubernetes_kubernetes)

        Page::Group::Kubernetes::Kubernetes::Index.perform(
          &:add_kubernetes_cluster)

        Page::Group::Kubernetes::Kubernetes::Add.perform(
          &:add_existing_cluster)

        Page::Group::Kubernetes::Kubernetes::AddExisting.perform do |page|
          page.set_cluster_name(@cluster.cluster_name)
          page.set_api_url(@cluster.api_url)
          page.set_ca_certificate(@cluster.ca_certificate)
          page.set_token(@cluster.token)
          page.check_rbac! if @cluster.rbac
          page.add_cluster!
        end

        if @install_helm_tiller
          Page::Group::Kubernetes::Kubernetes::Show.perform do |page|
            # We must wait a few seconds for permissions to be set up correctly for new cluster
            sleep 10

            # Helm must be installed before everything else
            page.install!(:helm)
            page.await_installed(:helm)

            page.install!(:ingress) if @install_ingress

            page.await_installed(:ingress) if @install_ingress
          end
        end
      end
    end
  end
end
