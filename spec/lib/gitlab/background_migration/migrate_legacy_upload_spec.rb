require 'spec_helper'

describe Gitlab::BackgroundMigration::MigrateLegacyUploads, :migration, schema: 20190103140724 do
  let(:test_dir) { FileUploader.options['storage_path'] }

  let!(:namespace) { create(:namespace) }
  let!(:project) { create(:project, :legacy_storage, namespace: namespace) }
  let!(:issue) { create(:issue, project: project) }

  let!(:note1) { create(:note, note: 'some note text awesome', project: project, noteable: issue) }
  let!(:note2) { create(:note, note: 'some note', project: project, noteable: issue) }

  let!(:hashed_project) { create(:project, namespace: namespace) }
  let!(:issue_hashed_project) { create(:issue, project: hashed_project) }
  let!(:note_hashed_project) { create(:note, note: 'some note', project: hashed_project, attachment: 'text.pdf', noteable: issue_hashed_project) }

  let!(:standard_upload) do
    create(:upload,
      path: "secretabcde/image.png",
      model_id: create(:project).id, model_type: 'Project', uploader: 'FileUploader')
  end

  def new_upload_legacy
    Upload.find_by(model_id: project.id, model_type: 'Project')
  end

  def new_upload_hashed
    Upload.find_by(model_id: hashed_project.id, model_type: 'Project')
  end

  shared_examples 'migrates files correctly' do
    before do
      described_class.new.perform
    end

    it 'removes all the legacy upload records' do
      expect(Upload.where(uploader: 'AttachmentUploader')).to be_empty

      expect(standard_upload.reload).to eq(standard_upload)
    end

    it 'creates new upload records correctly' do
      expect(new_upload_legacy.secret).not_to be_nil
      expect(new_upload_legacy.path).to end_with("#{new_upload_legacy.secret}/image.png")
      expect(new_upload_legacy.model_id).to eq(project.id)
      expect(new_upload_legacy.model_type).to eq('Project')
      expect(new_upload_legacy.uploader).to eq('FileUploader')

      expect(new_upload_hashed.secret).not_to be_nil
      expect(new_upload_hashed.path).to end_with("#{new_upload_hashed.secret}/text.pdf")
      expect(new_upload_hashed.model_id).to eq(hashed_project.id)
      expect(new_upload_hashed.model_type).to eq('Project')
      expect(new_upload_hashed.uploader).to eq('FileUploader')
    end

    it 'updates the legacy upload notes so that they include the file references in the markdown' do
      expected_path = File.join('/uploads', new_upload_legacy.secret, 'image.png')
      expected_markdown = "some note text awesome \n ![image](#{expected_path})"
      expect(note1.reload.note).to eq(expected_markdown)

      expected_path = File.join('/uploads', new_upload_hashed.secret, 'text.pdf')
      expected_markdown = "some note \n [text.pdf](#{expected_path})"
      expect(note_hashed_project.reload.note).to eq(expected_markdown)
    end

    it 'removed the attachments from the note model' do
      expect(note1.reload.attachment.file).to be_nil
      expect(note2.reload.attachment.file).to be_nil
      expect(note_hashed_project.reload.attachment.file).to be_nil
    end
  end

  context 'when legacy uploads are stored in local storage' do
    let!(:legacy_upload1) do
      temp_upload = create(:upload, :with_file, :attachment_upload,
        path: "uploads/-/system/note/attachment/#{note1.id}/image.png", model: note1)

      note1.update(attachment: temp_upload.build_uploader)
      note1.attachment.upload
    end
    let!(:legacy_upload_not_found) do
      upload = create(:upload, :attachment_upload,
         path: "uploads/-/system/note/attachment/#{note2.id}/non-existing.pdf", model: note2)

      note2.update(attachment: upload.build_uploader)
      upload
    end
    let!(:legacy_upload_hashed) do
      temp_upload = create(:upload, :with_file, :attachment_upload,
        path: "uploads/-/system/note/attachment/#{note_hashed_project.id}/text.pdf", model: note_hashed_project)

      note_hashed_project.update(attachment: temp_upload.build_uploader)
      note_hashed_project.attachment.upload
    end

    shared_examples 'removes legacy local files' do
      it 'removes all the legacy upload records' do
        expect(File.exist?(legacy_upload1.absolute_path)).to be_truthy
        expect(File.exist?(legacy_upload_hashed.absolute_path)).to be_truthy

        described_class.new.perform

        expect(File.exist?(legacy_upload1.absolute_path)).to be_falsey
        expect(File.exist?(legacy_upload_hashed.absolute_path)).to be_falsey
      end
    end

    context 'when object storage is disabled for FileUploader' do
      it_behaves_like 'migrates files correctly'
      it_behaves_like 'removes legacy local files'

      it 'moves legacy uploads to the correct location' do
        described_class.new.perform

        expected_path1 = File.join(test_dir, 'uploads', namespace.path, project.path, new_upload_legacy.secret, 'image.png')
        expected_path2 = File.join(test_dir, 'uploads', hashed_project.disk_path, new_upload_hashed.secret, 'text.pdf')

        expect(File.exist?(expected_path1)).to be_truthy
        expect(File.exist?(expected_path2)).to be_truthy
      end

      context 'when the upload move fails' do
        it 'does not remove old uploads' do
          expect(FileUploader).to receive(:copy_to).twice.and_return(nil)

          described_class.new.perform

          expect(legacy_upload1.reload).to eq(legacy_upload1)
          expect(legacy_upload_hashed.reload).to eq(legacy_upload_hashed)
          expect(standard_upload.reload).to eq(standard_upload)
        end
      end
    end

    context 'when object storage is enabled for FileUploader' do
      before do
        stub_uploads_object_storage(FileUploader)
      end

      it_behaves_like 'migrates files correctly'
      it_behaves_like 'removes legacy local files'

      # The process of migrating to object storage is a manual one,
      # so it would go against expectations to automatically migrate these files
      # to object storage during this migration.
      # After this migration, these files should be able to successfully migrate to object storage.
      it 'stores files locally' do
        described_class.new.perform

        expected_path1 = File.join(test_dir, 'uploads', namespace.path, project.path, new_upload_legacy.secret, 'image.png')
        expected_path2 = File.join(test_dir, 'uploads', hashed_project.disk_path, new_upload_hashed.secret, 'text.pdf')

        expect(File.exist?(expected_path1)).to be_truthy
        expect(File.exist?(expected_path2)).to be_truthy
      end
    end

    context 'with legacy_diff_note upload' do
      let!(:merge_request) { create(:merge_request, source_project: project) }
      let!(:legacy_diff_note) { create(:legacy_diff_note_on_merge_request, note: 'some note', project: project, noteable: merge_request) }
      let!(:legacy_upload_diff_note) do
        create(:upload, :with_file, :attachment_upload,
               path: "uploads/-/system/note/attachment/#{legacy_diff_note.id}/some_legacy.pdf", model: legacy_diff_note)
      end

      before do
        described_class.new.perform
      end

      it 'does not remove legacy diff note file' do
        expect(File.exist?(legacy_upload_diff_note.absolute_path)).to be_truthy
      end

      it 'removes all the legacy upload records except for the one with legacy_diff_note' do
        expect(Upload.where(uploader: 'AttachmentUploader')).to eq([legacy_upload_diff_note])
      end
    end
  end

  context 'when legacy uploads are stored in object storage' do
    let!(:legacy_upload1) do
      create(:upload,
             path: "note/attachment/#{note1.id}/image.png", mount_point: 'attachment', store: ObjectStorage::Store::REMOTE,
             model_id: note1.id, model_type: 'Note', uploader: 'AttachmentUploader', secret: nil)
    end
    let!(:legacy_upload_not_found) do
      create(:upload,
             path: "note/attachment/#{note2.id}/non-existing.pdf", mount_point: 'attachment', store: ObjectStorage::Store::REMOTE,
             model_id: note2.id, model_type: 'Note', uploader: 'AttachmentUploader', secret: nil)
    end
    let!(:legacy_upload_hashed) do
      create(:upload,
             path: "note/attachment/#{note_hashed_project.id}/text.pdf", mount_point: 'attachment', store: ObjectStorage::Store::REMOTE,
             model_id: note_hashed_project.id, model_type: 'Note', uploader: 'AttachmentUploader', secret: nil)
    end
    let(:remote_files) do
      [
        { key:  "#{legacy_upload1.path}" },
        { key: "#{legacy_upload_hashed.path}" }
      ]
    end
    let(:connection) { ::Fog::Storage.new(FileUploader.object_store_credentials) }
    let(:bucket) { connection.directories.create(key: 'uploads') }

    def create_remote_files
      remote_files.each { |file| bucket.files.create(file) }
    end

    before do
      stub_uploads_object_storage(FileUploader)
      create_remote_files
    end

    it_behaves_like 'migrates files correctly'

    it 'moves legacy uploads to the correct remote location' do
      described_class.new.perform

      connection = ::Fog::Storage.new(FileUploader.object_store_credentials)
      expect(connection.get_object('uploads', new_upload_legacy.path)[:status]).to eq(200)
      expect(connection.get_object('uploads', new_upload_hashed.path)[:status]).to eq(200)
    end

    it 'removes all the legacy upload records' do
      described_class.new.perform

      remote_files.each do |remote_file|
        expect(bucket.files.get(remote_file[:key])).to be_nil
      end
    end
  end
end
