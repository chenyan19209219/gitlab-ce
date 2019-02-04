# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::ListSentryProjectsService do
  set(:user) { create(:user) }
  set(:project) { create(:project) }

  let(:sentry_url) { 'https://sentrytest.gitlab.com/api/0/projects/sentry-org/sentry-project' }
  let(:token) { 'test-token' }
  let(:new_api_host) { 'https://gitlab.com/' }
  let(:new_token) { 'new-token' }
  let(:params) { ActionController::Parameters.new(api_host: new_api_host, token: new_token) }

  let(:error_tracking_setting) do
    create(:project_error_tracking_setting, api_url: sentry_url, token: token, project: project)
  end

  subject { described_class.new(project, user, params) }

  before do
    project.add_reporter(user)
  end

  describe '#execute' do
    context 'with authorized user' do
      before do
        expect(project).to receive(:error_tracking_setting).at_least(:once)
          .and_return(error_tracking_setting)
      end

      it 'uses new api_url and token' do
        sentry_client = spy(:sentry_client)

        expect(Sentry::Client).to receive(:new)
          .with(new_api_host + 'api/0/projects/', new_token).and_return(sentry_client)
        expect(sentry_client).to receive(:list_projects).and_return([])

        subject.execute
      end

      context 'sentry client raises exception' do
        it 'returns error response' do
          expect(error_tracking_setting).to receive(:list_sentry_projects)
            .and_raise(Sentry::Client::Error, 'Sentry response error: 500')

          subject = described_class.new(project, user, params)
          result = subject.execute

          expect(result[:message]).to eq('Sentry response error: 500')
          expect(result[:http_status]).to eq(:bad_request)
        end
      end

      context 'with invalid url' do
        let(:params) do
          ActionController::Parameters.new(
            api_host: 'https://localhost',
            token: new_token
          )
        end

        subject { described_class.new(project, user, params) }

        before do
          error_tracking_setting.enabled = false
        end

        it 'returns error' do
          result = subject.execute

          expect(error_tracking_setting).not_to be_valid
          expect(result[:message]).to start_with('Api url is blocked')
        end
      end

      context 'when list_sentry_projects returns projects' do
        let(:projects) { [:list, :of, :projects] }

        before do
          expect(error_tracking_setting)
            .to receive(:list_sentry_projects).and_return(projects: projects)
        end

        it 'returns the projects' do
          result = subject.execute

          expect(result).to eq(status: :success, projects: projects)
        end
      end
    end

    context 'with unauthorized user' do
      let(:unauthorized_user) { create(:user) }

      subject { described_class.new(project, unauthorized_user) }

      it 'returns error' do
        result = subject.execute

        expect(result).to include(status: :error, message: 'access denied')
      end
    end

    context 'with error tracking disabled' do
      before do
        expect(project).to receive(:error_tracking_setting).at_least(:once)
          .and_return(error_tracking_setting)
        expect(error_tracking_setting)
          .to receive(:list_sentry_projects).and_return(projects: [])

        error_tracking_setting.enabled = false
      end

      it 'ignores enabled flag' do
        result = subject.execute

        expect(result).to include(status: :success, projects: [])
      end
    end

    context 'error_tracking_setting is nil' do
      before do
        expect(project).to receive(:error_tracking_setting).at_least(:once)
          .and_return(nil)
      end

      it 'builds a new error_tracking_setting' do
        sentry_client = spy(:sentry_client)

        expect(Sentry::Client).to receive(:new)
          .with(new_api_host + 'api/0/projects/', new_token)
          .and_return(sentry_client)

        expect(sentry_client).to receive(:list_projects)
          .and_return([:project1, :project2])

        result = subject.execute

        expect(result[:projects]).to eq([:project1, :project2])
        expect(project.error_tracking_setting).to be_nil
      end
    end
  end
end
