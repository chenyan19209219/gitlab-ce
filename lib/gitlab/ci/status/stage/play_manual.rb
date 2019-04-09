# frozen_string_literal: true

module Gitlab
  module Ci
    module Status
      module Stage
        class PlayManual < Status::Extended
          include GitlabRoutingHelper

          def label
            'play all manual'
          end

          def action_icon
            'play'
          end

          def action_button_title
            _('Play all manual')
          end

          def action_title
            'Play all manual'
          end

          def action_path
            play_all_project_stage_path(subject.pipeline, subject.name)
          end

          def action_method
            :post
          end

          def self.matches?(stage, user)
            stage.blocked_or_skipped? ||
              (stage.manual_playable? && stage.builds.manual.exists?)
          end

          def has_manual_builds?
            true
          end
        end
      end
    end
  end
end
