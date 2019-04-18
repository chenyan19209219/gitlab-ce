require 'spec_helper'

describe StageEntity do
  let(:pipeline) { create(:ci_pipeline) }
  let(:request) { double('request') }
  let(:user) { create(:user) }

  let(:entity) do
    described_class.new(stage, request: request)
  end

  let(:stage) do
    build(:ci_stage, pipeline: pipeline, name: 'test')
  end

  before do
    allow(request).to receive(:current_user).and_return(user)
    create(:ci_build, :success, pipeline: pipeline)
  end

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains relevant fields' do
      expect(subject).to include :name, :status, :path
    end

    it 'contains detailed status' do
      expect(subject[:status]).to include :text, :label, :group, :icon, :tooltip
      expect(subject[:status][:label]).to eq 'passed'
    end

    it 'contains valid name' do
      expect(subject[:name]).to eq 'test'
    end

    it 'contains path to the stage' do
      expect(subject[:path])
        .to include "pipelines/#{pipeline.id}##{stage.name}"
    end

    it 'contains path to the stage dropdown' do
      expect(subject[:dropdown_path])
        .to include "pipelines/#{pipeline.id}/stage.json?stage=test"
    end

    it 'contains stage title' do
      expect(subject[:title]).to eq 'test: passed'
    end

    it 'does not contain play_all_manual info' do
      expect(subject[:play_manual_details]).not_to be_present
    end

    context 'when the jobs should be grouped' do
      let(:entity) { described_class.new(stage, request: request, grouped: true) }

      it 'exposes the group key' do
        expect(subject).to include :groups
      end

      context 'and contains commit status' do
        before do
          create(:generic_commit_status, pipeline: pipeline, stage: 'test')
        end

        it 'contains commit status' do
          groups = subject[:groups].map { |group| group[:name] }
          expect(groups).to include('generic')
        end
      end
    end

    context 'when stage contains manual jobs' do
      let(:stage) { create(:ci_stage_entity, status: 'skipped', name: 'test') }

      before do
        create_list(:ci_build, 3, :manual, stage: 'test', stage_id: stage.id)
      end

      it 'contains play_all_manual' do
        expect(subject[:play_manual_details]).to be_present
      end
    end
  end
end
