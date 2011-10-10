class AddIndexesToBulkUploadStages < ActiveRecord::Migration
  def self.up
    add_index :bulk_upload_stages, [:bulk_upload_id, :selected]
  end

  def self.down
    remove_index :bulk_upload_stages, [:bulk_upload_id, :selected]
  end
end
