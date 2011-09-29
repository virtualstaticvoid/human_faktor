class CreateBulkUploads < ActiveRecord::Migration
  def self.up
    create_table :bulk_uploads do |t|
      t.references :account, :null => false

      t.integer :status, :null => false, :default => 0  # STATUS_PENDING
      t.string :comment, :length => 255
      t.text :error_messages

      # csv_file for bulk upload
      t.string :csv_file_file_name
      t.string :csv_file_content_type
      t.integer :csv_file_file_size
      t.datetime :csv_file_updated_at
      
      t.timestamps
    end
    add_index :bulk_uploads, :account_id
  end

  def self.down
    drop_table :bulk_uploads
  end
end
