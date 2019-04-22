# frozen_string_literal: true

module Ci
  class PlayStageManualBuildsService < BaseService
    include Gitlab::Utils::StrongMemoize

    def initialize(project, current_user, params)
      super

      @pipeline = params[:pipeline]
      @stage = params[:stage]
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless can?(current_user, :update_pipeline, pipeline)

      manual_builds.map(&:enqueue)
      manual_builds.update(user_id: current_user.id)
    end

    private

    attr_reader :pipeline, :stage

    def manual_builds
      strong_memoize(:manual_builds) do
        stage.builds.manual
      end
    end
  end
end
