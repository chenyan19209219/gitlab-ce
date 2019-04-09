# frozen_string_literal: true

require 'spec_helper'

describe Ci::PlayStageManualBuildsService, '#execute' do
  let(:pipeline) { create(:ci_pipeline) }
  let(:project) { pipeline.project }
  let(:stage) { create(:ci_stage_entity, pipeline: pipeline, project: project, name: 'test') }
  let(:current_user) { create(:user) }

  let(:service) do
    described_class.new(project, current_user)
  end

  before do
    project.add_maintainer(current_user)
  end

  context 'when pipeline has manual builds' do
    before do
      create_list(:ci_build, 3, :manual,
                  pipeline: pipeline,
                  stage: 'test',
                  stage_id: stage.id)

      service.execute(stage)
      pipeline.reload
    end

    it 'starts manual builds from pipeline' do
      expect(pipeline.builds.manual.count).to eq(0)
    end
  end

  context 'when pipeline has no manual builds' do
    before do
      create_list(:ci_build, 2, :failed,
                pipeline: pipeline,
                stage: 'build')

      service.execute(pipeline)
      pipeline.reload
    end

    it 'does not update the builds' do
      expect(pipeline.builds.failed.count).to eq(2)
    end
  end
end
