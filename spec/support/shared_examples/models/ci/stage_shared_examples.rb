# frozen_string_literal: true

shared_examples 'stage manual builds' do |stage_factory|
  subject { stage.manual_playable? }

  context 'when it has a manual playable status' do
    let(:stage) { create(stage_factory, status: 'success') }

    context 'and manual builds' do
      before do
        create_manual_builds(stage)
      end

      it { is_expected.to be_truthy }
    end

    context 'and no manual builds' do
      it { is_expected.to be_falsy }
    end
  end

  context 'when it has any other status' do
    let(:stage) { create(stage_factory, status: 'canceled') }

    it { is_expected.to be_falsy }
  end
end
