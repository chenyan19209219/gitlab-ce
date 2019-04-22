# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Status::Stage::PlayManual do
  let(:stage) { double('stage') }
  let(:play_manual) { described_class.new(stage) }

  describe '#action_icon' do
    subject { play_manual.action_icon }

    it { is_expected.to eq('play') }
  end

  describe '#action_button_title' do
    subject { play_manual.action_button_title }

    it { is_expected.to eq('Play all manual') }
  end

  describe '#action_title' do
    subject { play_manual.action_title }

    it { is_expected.to eq('Play all manual') }
  end

  describe '#action_path' do
    let(:stage) { create(:ci_stage_entity, status: 'manual') }
    let(:pipeline) { stage.pipeline }
    let(:project) { pipeline.project }
    let(:status) { Gitlab::Ci::Status::Core.new(stage, create(:user)) }

    subject { described_class.new(status).action_path }

    it { is_expected.to eq("/#{project.full_path}/pipelines/#{pipeline.id}/stages/#{stage.name}/play_all_manual") }
  end

  describe '#action_method' do
    subject { play_manual.action_method }

    it { is_expected.to eq(:post) }
  end

  describe '.matches?' do
    let(:user) { double('user') }

    subject { described_class.matches?(stage, user) }

    context 'when stage is skipped' do
      let(:stage) { create(:ci_stage_entity, status: :skipped) }

      it { is_expected.to be_truthy }
    end

    context 'when stage is manual' do
      let(:stage) { create(:ci_stage_entity, status: :manual) }

      it { is_expected.to be_truthy }
    end

    context 'when stage is scheduled' do
      let(:stage) { create(:ci_stage_entity, status: :scheduled) }

      it { is_expected.to be_truthy }
    end

    context 'when stage is success' do
      let(:stage) { create(:ci_stage_entity, status: :success, name: 'build') }

      context 'and has manual builds' do
        before do
          create_list(:ci_build, 2, :manual, stage: 'build', stage_id: stage.id)
        end

        it { is_expected.to be_truthy }
      end

      context 'and does not have manual builds' do
        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#has_manual_builds?' do
    subject { play_manual.has_manual_builds? }

    it { is_expected.to be_truthy }
  end
end
