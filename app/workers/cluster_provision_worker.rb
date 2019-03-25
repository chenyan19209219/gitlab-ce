# frozen_string_literal: true

class ClusterProvisionWorker
  include ApplicationWorker
  include ClusterQueue

  def perform(cluster_id)
    Clusters::Cluster.find_by_id(cluster_id).try do |cluster|
      cluster.provider.try do |provider|
        Clusters::Gcp::ProvisionService.new.execute(provider) if cluster.gcp?
      end

      ClusterConfigureWorker.perform_async(cluster.id) if configure_kubernetes_resources?(cluster)
    end
  end

  private

  def configure_kubernetes_resources?(cluster)
    cluster.user? && cluster.managed?
  end
end
