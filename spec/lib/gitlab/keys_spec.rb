# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Keys do
  let(:logger) { double('logger').as_null_object }

  subject { described_class.new(logger) }

  describe '#add_key' do
    it "adds a line at the end of the file and strips trailing garbage" do
      create_authorized_keys_fixture
      subject.add_key('key-741', 'ssh-rsa AAAAB3NzaDAxx2E trailing garbage')
      auth_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-741\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaDAxx2E"
      expect(File.read(authorized_keys_file)).to eq("existing content\n#{auth_line}\n")
    end

    context "without file writing" do
      before { allow(subject).to receive(:open) }
      before { create_authorized_keys_fixture }

      it "should log an add-key event" do
        expect(logger).to receive(:info).with('Adding key (key-741): ssh-rsa AAAAB3NzaDAxx2E')
        subject.add_key('key-741', 'ssh-rsa AAAAB3NzaDAxx2E')
      end

      it "should return true" do
        expect(subject.add_key('key-741', 'ssh-rsa AAAAB3NzaDAxx2E')).to be_truthy
      end
    end
  end

  describe '#batch_add_keys' do
    let(:keys) do
      [
        {id: 'key-12', key: 'ssh-dsa ASDFASGADG trailing garbage'},
        {id: 'key-123', key: 'ssh-rsa GFDGDFSGSDFG'},
      ]
    end

    before do
      create_authorized_keys_fixture
    end

    it "adds lines at the end of the file" do
      subject.batch_add_keys(keys)
      auth_line1 = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-12\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-dsa ASDFASGADG"
      auth_line2 = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-123\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa GFDGDFSGSDFG"
      expect(File.read(authorized_keys_file)).to eq("existing content\n#{auth_line1}\n#{auth_line2}\n")
    end

    context "without file writing" do
      before do
        expect(subject).to receive(:open).and_yield(double(:file, puts: nil, chmod: nil))
      end

      it "should log an add-key event" do
        expect(logger).to receive(:info).with('Adding key (key-12): ssh-dsa ASDFASGADG')
        expect(logger).to receive(:info).with('Adding key (key-123): ssh-rsa GFDGDFSGSDFG')

        subject.batch_add_keys(keys)
      end

      it "should return true" do
        expect(subject.batch_add_keys(keys)).to be_truthy
      end
    end
  end

  describe '#rm_key' do
    it "removes the right line" do
      create_authorized_keys_fixture
      other_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-742\",options ssh-rsa AAAAB3NzaDAxx2E"
      delete_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-741\",options ssh-rsa AAAAB3NzaDAxx2E"
      open(authorized_keys_file, 'a') do |auth_file|
        auth_file.puts delete_line
        auth_file.puts other_line
      end
      subject.rm_key('key-741')
      erased_line = delete_line.gsub(/./, '#')
      expect(File.read(authorized_keys_file)).to eq("existing content\n#{erased_line}\n#{other_line}\n")
    end

    context "without file writing" do
      before do
        allow(subject).to receive(:open)
      end

      it "should log an rm-key event" do
        expect(logger).to receive(:info).with('Removing key (key-741)')

        subject.rm_key('key-741')
      end

      it "should return true" do
        expect(subject.rm_key('key-741')).to be_truthy
      end
    end
  end

  describe '#clear' do
    it "should return true" do
      allow(subject).to receive(:open)
      expect(subject.clear).to be_truthy
    end
  end

  def create_authorized_keys_fixture(existing_content: 'existing content')
    FileUtils.mkdir_p(File.dirname(authorized_keys_file))
    open(authorized_keys_file, 'w') { |file| file.puts(existing_content) }
  end

  def authorized_keys_file
    Gitlab::CurrentSettings.current_application_settings.authorized_keys_file
  end
end
