# frozen_string_literal: true

# Gitlab::VisibilityLevel module
#
# Define allowed public modes that can be used for
# GitLab projects to determine project public mode
#
module Gitlab
  module VisibilityLevel
    extend ActiveSupport::Concern

    included do
      scope :public_only,               -> { where(visibility_level: PUBLIC) }
      scope :public_and_internal_only,  -> { where(visibility_level: [PUBLIC, INTERNAL] ) }
      scope :non_public_only,           -> { where.not(visibility_level: PUBLIC) }

      scope :public_to_user, -> (user = nil) do
        where(visibility_level: VisibilityLevel.levels_for_user(user))
      end
    end

    PRIVATE  = 0 unless const_defined?(:PRIVATE)
    SECRET   = 5 unless const_defined?(:SECRET)
    INTERNAL = 10 unless const_defined?(:INTERNAL)
    PUBLIC   = 20 unless const_defined?(:PUBLIC)

    class << self
      def levels_for_user(user = nil)
        return [PUBLIC] unless user

        if user.full_private_access?
          [PRIVATE, INTERNAL, PUBLIC]
        elsif user.external?
          [PUBLIC]
        else
          [INTERNAL, PUBLIC]
        end
      end

      def values_for(model)
        case model
        when PersonalSnippet
          all_values
        else
          values
        end
      end

      def options
        {
          N_('VisibilityLevel|Private')  => PRIVATE,
          N_('VisibilityLevel|Internal') => INTERNAL,
          N_('VisibilityLevel|Public')   => PUBLIC
        }
      end

      def values
        options.values
      end

      def all_options
        {
          N_('VisibilityLevel|Private')  => PRIVATE,
          N_('VisibilityLevel|Secret')   => SECRET,
          N_('VisibilityLevel|Internal') => INTERNAL,
          N_('VisibilityLevel|Public')   => PUBLIC
        }
      end

      def all_values
        all_options.values
      end

      def string_options
        {
          'private'  => PRIVATE,
          'secret'   => SECRET,
          'internal' => INTERNAL,
          'public'   => PUBLIC
        }
      end

      def string_values
        string_options.keys
      end

      def allowed_levels
        restricted_levels = Gitlab::CurrentSettings.restricted_visibility_levels

        self.values - Array(restricted_levels)
      end

      def closest_allowed_level(target_level)
        highest_allowed_level = allowed_levels.select { |level| level <= target_level }.max

        # If all levels are restricted, fall back to PRIVATE
        highest_allowed_level || PRIVATE
      end

      def allowed_for?(user, level)
        user.admin? || allowed_level?(level.to_i)
      end

      # Level should be a numeric value, e.g. `20`
      # Return true if the specified level is allowed for the current user.
      def allowed_level?(level)
        valid_level?(level) && non_restricted_level?(level)
      end

      def non_restricted_level?(level)
        restricted_levels = Gitlab::CurrentSettings.restricted_visibility_levels

        if restricted_levels.nil?
          true
        else
          !restricted_levels.include?(level)
        end
      end

      def valid_level?(level)
        options.value?(level)
      end

      def level_name(level)
        level_name = N_('VisibilityLevel|Unknown')
        options.each do |name, lvl|
          level_name = name if lvl == level.to_i
        end

        s_(level_name)
      end

      def level_value(level)
        return level.to_i if level.to_i.to_s == level.to_s && string_options.key(level.to_i)

        string_options[level] || PRIVATE
      end

      def string_level(level)
        string_options.key(level)
      end
    end

    def private?
      visibility_level_value == PRIVATE
    end

    def internal?
      visibility_level_value == INTERNAL
    end

    def public?
      visibility_level_value == PUBLIC
    end

    # Cannot use `secret?` as Snippet's attr_encrypted :secret already defines
    # a #secret?
    def visibility_secret?
      visibility_level_value == SECRET
    end

    def visibility_level_value
      self[visibility_level_field]
    end

    def visibility
      Gitlab::VisibilityLevel.string_level(visibility_level_value)
    end

    def visibility=(level)
      self[visibility_level_field] = Gitlab::VisibilityLevel.level_value(level)
    end
  end
end
