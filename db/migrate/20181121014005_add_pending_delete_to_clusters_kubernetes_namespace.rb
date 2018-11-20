# frozen_string_literal: true

class AddPendingDeleteToClustersKubernetesNamespace < ActiveRecord::Migration
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default :clusters_kubernetes_namespaces, :pending_delete, :boolean, default: false
  end

  def down
    remove_column :clusters_kubernetes_namespaces, :pending_delete
  end
end
