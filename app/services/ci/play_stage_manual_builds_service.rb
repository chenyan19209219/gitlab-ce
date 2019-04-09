# frozen_string_literal: true

module Ci
  class PlayStageManualBuildsService < BaseService
    include Gitlab::Utils::StrongMemoize

    def execute(stage)
      @stage = stage

      manual_builds.each do |build|
        build.play(current_user)
      end
    end

    private

    attr_reader :stage

    def manual_builds
      strong_memoize(:manual_builds) do
        stage.builds.manual
      end
    end
  end
end
