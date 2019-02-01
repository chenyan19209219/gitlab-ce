# frozen_string_literal: true

require 'spec_helper'

describe ErrorTracking::ProjectErrorTrackingSetting do
  include ReactiveCachingHelpers

  set(:project) { create(:project) }

  subject { create(:project_error_tracking_setting, project: project) }

  describe 'Associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'Validations' do
    context 'when api_url is over 255 chars' do
      before do
        subject.api_url = 'https://' + 'a' * 250
      end

      it 'fails validation' do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:api_url]).to include('is too long (maximum is 255 characters)')
      end
    end

    context 'With unsafe url' do
      it 'fails validation' do
        subject.api_url = "https://replaceme.com/'><script>alert(document.cookie)</script>"

        expect(subject).not_to be_valid
      end
    end

    context 'when enabled' do
      context 'when token missing' do
        it 'fails validation' do
          subject.token = nil

          expect(subject).not_to be_valid
        end
      end

      context 'when api_url missing' do
        it 'fails validation' do
          subject.api_url = nil

          expect(subject).not_to be_valid
        end
      end
    end

    context 'when disabled' do
      before do
        subject.enabled = false
      end

      context 'token missing' do
        it 'passes validation' do
          subject.token = nil

          expect(subject).to be_valid
        end
      end

      context 'when api_url missing' do
        it 'passes validation' do
          subject.api_url = nil

          expect(subject).to be_valid
        end
      end
    end

    context 'URL path' do
      it 'fails validation with wrong path' do
        subject.api_url = 'http://gitlab.com/project1/something'

        expect(subject).not_to be_valid
        expect(subject.errors.messages[:api_url]).to include('path needs to start with /api/0/projects')
      end

      it 'passes validation with correct path' do
        subject.api_url = 'http://gitlab.com/api/0/projects/project1/something'

        expect(subject).to be_valid
      end
    end

    context 'non ascii chars in api_url' do
      before do
        subject.api_url = 'http://gitlab.com/api/0/projects/project1/something€'
      end

      it 'fails validation' do
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#sentry_external_url' do
    let(:sentry_url) { 'https://sentrytest.gitlab.com/api/0/projects/sentry-org/sentry-project' }

    before do
      subject.api_url = sentry_url
    end

    it 'returns the correct url' do
      expect(subject.class).to receive(:extract_sentry_external_url).with(sentry_url).and_call_original

      result = subject.sentry_external_url

      expect(result).to eq('https://sentrytest.gitlab.com/sentry-org/sentry-project')
    end
  end

  describe '#sentry_client' do
    it 'returns sentry client' do
      expect(subject.sentry_client).to be_a(Sentry::Client)
    end
  end

  describe '#list_sentry_issues' do
    let(:issues) { [:list, :of, :issues] }

    let(:opts) do
      { issue_status: 'unresolved', limit: 10 }
    end

    let(:result) do
      subject.list_sentry_issues(**opts)
    end

    context 'when cached' do
      let(:sentry_client) { spy(:sentry_client) }

      before do
        stub_reactive_cache(subject, issues, opts)
        synchronous_reactive_cache(subject)

        expect(subject).to receive(:sentry_client).and_return(sentry_client)
      end

      it 'returns cached issues' do
        expect(sentry_client).to receive(:list_issues).with(opts)
          .and_return(issues)

        expect(result).to eq(issues: issues)
      end
    end

    context 'when not cached' do
      it 'returns nil' do
        expect(subject).not_to receive(:sentry_client)

        expect(result).to be_nil
      end
    end
  end

  describe '#list_sentry_projects' do
    let(:projects) { [:list, :of, :projects] }
    let(:sentry_client) { spy(:sentry_client) }

    it 'calls sentry client' do
      expect(subject).to receive(:sentry_client).and_return(sentry_client)
      expect(sentry_client).to receive(:list_projects).and_return(projects)

      result = subject.list_sentry_projects

      expect(result).to eq(projects: projects)
    end
  end

  describe '#project_slug' do
    context 'when api_url is correct' do
      before do
        subject.api_url = 'http://gitlab.com/api/0/projects/org-slug/project-slug'
      end

      it 'returns slug' do
        expect(subject.project_slug).to eq('project-slug')
      end
    end

    context 'when api_url is blank' do
      before do
        subject.api_url = nil
      end

      it 'returns nil' do
        expect(subject.project_slug).to be_nil
      end
    end
  end

  describe '#organization_slug' do
    context 'when api_url is correct' do
      before do
        subject.api_url = 'http://gitlab.com/api/0/projects/org-slug/project-slug'
      end

      it 'returns slug' do
        expect(subject.organization_slug).to eq('org-slug')
      end
    end

    context 'when api_url is blank' do
      before do
        subject.api_url = nil
      end

      it 'returns nil' do
        expect(subject.organization_slug).to be_nil
      end
    end
  end

  context 'names from api_url' do
    shared_examples_for 'name from api_url' do |name, titleized_slug|
      context 'name is present in DB' do
        it 'returns name from DB' do
          subject[name] = 'Sentry name'
          subject.api_url = 'http://gitlab.com/api/0/projects/org-slug/project-slug'

          expect(subject.public_send(name)).to eq('Sentry name')
        end
      end

      context 'name is null in DB' do
        it 'titleizes and returns slug from api_url' do
          subject[name] = nil
          subject.api_url = 'http://gitlab.com/api/0/projects/org-slug/project-slug'

          expect(subject.public_send(name)).to eq(titleized_slug)
        end

        it 'returns nil when api_url is incorrect' do
          subject[name] = nil
          subject.api_url = 'http://gitlab.com/api/0/projects/'

          expect(subject.public_send(name)).to be_nil
        end

        it 'returns nil when api_url is blank' do
          subject[name] = nil
          subject.api_url = nil

          expect(subject.public_send(name)).to be_nil
        end
      end
    end

    it_behaves_like 'name from api_url', :organization_name, 'Org Slug'
    it_behaves_like 'name from api_url', :project_name, 'Project Slug'
  end

  describe '.build_api_url_from' do
    it 'correctly builds api_url with slugs' do
      api_url = described_class.build_api_url_from(
        api_host: 'http://sentry.com/',
        organization_slug: 'org-slug',
        project_slug: 'proj-slug'
      )

      expect(api_url).to eq('http://sentry.com/api/0/projects/org-slug/proj-slug/')
    end

    it 'correctly builds api_url without slugs' do
      api_url = described_class.build_api_url_from(
        api_host: 'http://sentry.com/',
        organization_slug: nil,
        project_slug: nil
      )

      expect(api_url).to eq('http://sentry.com/api/0/projects/')
    end
  end

  describe '#api_host' do
    before do
      subject.api_url = 'https://example.com/api/0/projects/org-slug/proj-slug/'
    end

    it 'extracts the api_host from api_url' do
      expect(subject.api_host).to eq('https://example.com/')
    end
  end
end
