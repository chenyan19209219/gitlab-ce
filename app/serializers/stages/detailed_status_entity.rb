# frozen_string_literal: true

module Stages
  class DetailedStatusEntity < DetailedStatusEntity
    expose :manual_builds_details,
      if: -> (status, _) { status.has_manual_builds? },
      with: Stages::PlayManualEntity
  end
end
