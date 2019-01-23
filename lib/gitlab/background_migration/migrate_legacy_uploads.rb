# frozen_string_literal: true

# This migration takes all legacy uploads (that were uploaded using AttachmentUploader)
# and migrate them to the new (FileUploader) location (=under projects).
#
# We have dependencies (uploaders) in this migration because extracting code would add a lot of complexity
# and possible errors could appear as the logic in the uploaders is not trivial.
#
# This migration will be removed in 12.0 in order to get rid of a migration that depends on
# the application code.
module Gitlab
  module BackgroundMigration
    class MigrateLegacyUploads
      include Database::MigrationHelpers
      include ::Gitlab::Utils::StrongMemoize

      Upload.class_eval { include EachBatch } unless Upload < EachBatch

      class UploadMover
        include Gitlab::Utils::StrongMemoize

        attr_reader :upload, :project, :note

        def initialize(upload)
          @upload = upload
          @note = Note.find_by(id: upload.model_id)
          @project = note&.project
        end

        def execute
          return unless upload

          if !project
            # if we don't have models associated with the upload we can not move it
            say "MigrateLegacyUploads: Deleting upload due to model not found: #{upload.inspect}"
            destroy_upload = true
          elsif note.is_a?(LegacyDiffNote)
            say "MigrateLegacyUploads: LegacyDiffNote found, can't move the file: #{upload.inspect}. See TODO LINK"
          elsif !legacy_file_exists?
            # if we can not find the file we just remove the upload record
            say "MigrateLegacyUploads: Deleting upload due to file not found: #{upload.inspect}"
            destroy_upload = true
          elsif copy_upload_to_project
            add_upload_link_to_note_text
            destroy_legacy_file
            destroy_upload = true
          end

          destroy_legacy_upload if destroy_upload
        end

        private

        def copy_upload_to_project
          @uploader = FileUploader.copy_to(legacy_file_uploader, project)

          if @uploader
            say "MigrateLegacyUploads: Copied file #{legacy_file_uploader.file.path} -> #{@uploader.file.path}"
            true
          else
            say "MigrateLegacyUploads: File #{legacy_file_uploader.file.path} couldn't be copied to project uploads"
            false
          end
        end

        def destroy_legacy_upload
          note.remove_attachment = true
          note.save

          upload.destroy

          say "MigrateLegacyUploads: Upload #{upload.inspect} was destroyed."
        end

        def destroy_legacy_file
          legacy_file_uploader.file.delete
        end

        def add_upload_link_to_note_text
          new_text = "#{note.note} \n #{@uploader.markdown_link}"
          note.update!(
            note: new_text
          )
        end

        def legacy_file_uploader
          @legacy_file_uploader ||= upload.build_uploader
        end

        def legacy_file_exists?
          legacy_file_uploader.retrieve_from_store!(File.basename(upload.path))
          legacy_file_uploader.file.exists?
        end

        def say(message)
          Rails.logger.info(message)
        end
      end

      def perform
        Upload.where(uploader: 'AttachmentUploader').each_batch do |batch|
          batch.each { |upload| UploadMover.new(upload).execute }
        end
      end
    end
  end
end
