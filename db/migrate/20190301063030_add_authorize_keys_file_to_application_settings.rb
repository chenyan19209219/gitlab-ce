# frozen_string_literal: true

class AddAuthorizeKeysFileToApplicationSettings < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    add_column(:application_settings, :authorized_keys_file, :string)

    ApplicationSetting
      .where(authorized_keys_enabled: true)
      .update_all(authorized_keys_file: authorized_keys_file)
  end

  def down
    remove_column(:application_settings, :authorized_keys_file)
  end

  private

  def authorized_keys_file
    gitlab_shell_auth_file.presence || default_auth_file
  end

  def gitlab_shell_auth_file
    return unless Gitlab.config.gitlab_shell.present?

    config_file = File.join(File.expand_path(Gitlab.config.gitlab_shell.path), 'config.yml')

    YAML.load_file(config_file)["auth_file"] if File.exist?(config_file)
  end

  def default_auth_file
    File.join(ENV['HOME'], '.ssh/authorized_keys')
  end
end
