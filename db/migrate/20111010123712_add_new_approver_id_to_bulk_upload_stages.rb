class AddNewApproverIdToBulkUploadStages < ActiveRecord::Migration
  def self.up
    add_column :bulk_upload_stages, :new_approver_id, :integer
  end

  def self.down
    remove_column :bulk_upload_stages, :new_approver_id
  end
end
