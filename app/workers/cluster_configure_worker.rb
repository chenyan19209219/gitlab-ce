# frozen_string_literal: true

class ClusterConfigureWorker
  include ApplicationWorker
  include ClusterQueue

  def perform(cluster_id)
    return if Feature.enabled?(:ci_preparing_state, default_enabled: true)

    cluster = Clusters::Cluster.find_by_id(cluster_id)

    if cluster&.managed?
      Clusters::RefreshService.create_or_update_namespaces_for_cluster(cluster)
    end
  end
end
