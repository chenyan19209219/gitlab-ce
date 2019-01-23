# frozen_string_literal: true

class Clusters::Platforms::KubernetesController < Clusters::BaseController
  include RoutableActions

  before_action :cluster
  before_action :kubernetes, only: [:update]
  before_action :authorize_update_cluster!, only: [:update]


  def update
    kubernetes.update(update_params)

    if kubernetes.valid?
      respond_to do |format|
        format.json do
          head :no_content
        end
        format.html do
          flash[:notice] = _('Kubernetes cluster was successfully updated.')
          redirect_to cluster.show_path
        end
      end
    else
      respond_to do |format|
        format.html { render 'clusters/clusters/show' }
      end
    end
  end

  private

  def cluster
    @cluster ||= clusterable.clusters.find(params[:id])
                                 .present(current_user: current_user)
  end

  def kubernetes
    @kubernetes ||= cluster.platform_kubernetes
  end

  def update_params
    if cluster.managed?
      params.require(:platform_kubernetes).permit(:namespace)
    else
      params.require(:platform_kubernetes).permit(
        :api_url,
        :token,
        :ca_cert,
        :namespace,
        cluster_attributes: [
          :name
        ]
      )
    end
  end

  def authorize_update_cluster!
    access_denied! unless can?(current_user, :update_cluster, cluster)
  end

  def clusterable
    raise NotImplementedError
  end
end
