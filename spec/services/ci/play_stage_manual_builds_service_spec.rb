# frozen_string_literal: true

require 'spec_helper'

describe Ci::PlayStageManualBuildsService, '#execute' do
  let(:pipeline) { create(:ci_pipeline) }
  let(:project) { pipeline.project }
  let(:current_user) { create(:user) }

  let(:stage) do
    create(:ci_stage_entity,
           pipeline: pipeline,
           project: project,
           name: 'test')
  end

  let(:options) do
    {
      pipeline: stage.pipeline,
      stage: stage
    }
  end

  let(:service) do
    described_class.new(project, current_user, options)
  end

  context 'when user does not have access' do
    it 'throws an exception' do
      project.add_reporter(current_user)

      expect do
        service.execute
      end.to raise_error(Gitlab::Access::AccessDeniedError)
    end
  end

  context 'when user has access' do
    before do
      project.add_maintainer(current_user)
    end

    context 'when pipeline has manual builds' do
      before do
        create_builds_for_stage('manual')
        service.execute
        pipeline.reload
      end

      it 'starts manual builds from pipeline' do
        expect(pipeline.builds.manual.count).to eq(0)
      end

      it 'updates manual builds' do
        pipeline.builds.each do |build|
          expect(build.user).to eq(current_user)
        end
      end
    end

    context 'when pipeline has no manual builds' do
      before do
        create_builds_for_stage('failed')

        service.execute
        pipeline.reload
      end

      it 'does not update the builds' do
        expect(pipeline.builds.failed.count).to eq(3)
      end
    end
  end

  def create_builds_for_stage(status)
    create_list(:ci_build, 3, status: status, pipeline: pipeline, stage: stage.name, stage_id: stage.id)
  end
end
