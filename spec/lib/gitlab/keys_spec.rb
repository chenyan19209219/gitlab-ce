require 'spec_helper'

describe Gitlab::Keys do
  before do
    $logger = double('logger').as_null_object
  end

  subject { described_class.new('key-741', 'ssh-rsa AAAAB3NzaDAxx2E') }

  describe '#add_key' do
    it "adds a line at the end of the file" do
      create_authorized_keys_fixture
      subject.add_key
      auth_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-741\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaDAxx2E"
      expect(File.read(tmp_authorized_keys_path)).to eq("existing content\n#{auth_line}\n")
    end

    context "without file writing" do
      before { allow(subject).to receive(:open) }
      before { create_authorized_keys_fixture }

      it "should log an add-key event" do
        expect($logger).to receive(:info).with("Adding key", {key_id: "key-741", public_key: "ssh-rsa AAAAB3NzaDAxx2E"})
        subject.add_key
      end

      it "should return true" do
        expect(subject.add_key).to be_truthy
      end
    end
  end

  describe '#list_keys' do
    it 'adds a key and lists it' do
      create_authorized_keys_fixture
      subject.add_key
      auth_line1 = 'key-741 AAAAB3NzaDAxx2E'
      expect(subject.list_keys).to eq("#{auth_line1}\n")
    end
  end

  describe '#list_key_ids' do
    before do
      create_authorized_keys_fixture(
        existing_content:
          "key-1\tssh-dsa AAA\nkey-2\tssh-rsa BBB\nkey-3\tssh-rsa CCC\nkey-9000\tssh-rsa DDD\n"
      )
    end

    it 'outputs the key IDs, separated by newlines' do
      expect { subject.list_key_ids }.to output("1\n2\n3\n9000\n").to_stdout
    end
  end

  describe '#batch_add_keys' do
    let(:fake_stdin) { StringIO.new("key-12\tssh-dsa ASDFASGADG\nkey-123\tssh-rsa GFDGDFSGSDFG\n", 'r') }
    before do
      create_authorized_keys_fixture
      allow(subject).to receive(:stdin).and_return(fake_stdin)
    end

    it "adds lines at the end of the file" do
      subject.batch_add_keys
      auth_line1 = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-12\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-dsa ASDFASGADG"
      auth_line2 = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-123\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa GFDGDFSGSDFG"
      expect(File.read(tmp_authorized_keys_path)).to eq("existing content\n#{auth_line1}\n#{auth_line2}\n")
    end

    context "with invalid input" do
      let(:fake_stdin) { StringIO.new("key-12\tssh-dsa ASDFASGADG\nkey-123\tssh-rsa GFDGDFSGSDFG\nfoo\tbar\tbaz\n", 'r') }

      it "aborts" do
        expect(subject).to receive(:abort)
        subject.batch_add_keys
      end
    end

    context "without file writing" do
      before do
        expect(subject).to receive(:open).and_yield(double(:file, puts: nil, chmod: nil))
      end

      it "should log an add-key event" do
        expect($logger).to receive(:info).with("Adding key", key_id: 'key-12', public_key: "ssh-dsa ASDFASGADG")
        expect($logger).to receive(:info).with("Adding key", key_id: 'key-123', public_key: "ssh-rsa GFDGDFSGSDFG")

        subject.batch_add_keys
      end

      it "should return true" do
        expect(subject.batch_add_keys).to be_truthy
      end
    end
  end

  describe '#rm_key' do
    it "removes the right line" do
      create_authorized_keys_fixture
      other_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-742\",options ssh-rsa AAAAB3NzaDAxx2E"
      delete_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-741\",options ssh-rsa AAAAB3NzaDAxx2E"
      open(tmp_authorized_keys_path, 'a') do |auth_file|
        auth_file.puts delete_line
        auth_file.puts other_line
      end
      subject.rm_key
      erased_line = delete_line.gsub(/./, '#')
      expect(File.read(tmp_authorized_keys_path)).to eq("existing content\n#{erased_line}\n#{other_line}\n")
    end

    context "without file writing" do
      before do
        allow(subject).to receive(:open)
        allow(subject).to receive(:lock).and_yield
      end

      it "should log an rm-key event" do
        expect($logger).to receive(:info).with("Removing key", key_id: "key-741")

        subject.rm_key
      end

      it "should return true" do
        expect(subject.rm_key).to be_truthy
      end
    end

    context 'without key content' do
      subject { described_class.new('key-741') }

      it "removes the right line by key ID" do
        create_authorized_keys_fixture
        other_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-742\",options ssh-rsa AAAAB3NzaDAxx2E"
        delete_line = "command=\"#{Gitlab.config.gitlab_shell.path}/bin/gitlab-shell key-741\",options ssh-rsa AAAAB3NzaDAxx2E"
        open(tmp_authorized_keys_path, 'a') do |auth_file|
          auth_file.puts delete_line
          auth_file.puts other_line
        end
        subject.rm_key
        erased_line = delete_line.gsub(/./, '#')
        expect(File.read(tmp_authorized_keys_path)).to eq("existing content\n#{erased_line}\n#{other_line}\n")
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
    FileUtils.mkdir_p(File.dirname(tmp_authorized_keys_path))
    open(tmp_authorized_keys_path, 'w') { |file| file.puts(existing_content) }
    allow(subject).to receive(:auth_file).and_return(tmp_authorized_keys_path)
  end

  def tmp_authorized_keys_path
    File.join('tmp', 'authorized_keys')
  end

  def tmp_lock_file_path
    tmp_authorized_keys_path + '.lock'
  end

  def capture_stdout(&blk)
    old = $stdout
    $stdout = fake = StringIO.new
    blk.call
    fake.string
  ensure
    $stdout = old
  end
end
