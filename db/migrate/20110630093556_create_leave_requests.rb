class CreateLeaveRequests < ActiveRecord::Migration
  def self.up
    create_table :leave_requests do |t|
      t.references :account, :null => false

      t.string :identifier, :null => false
      t.references :employee, :null => false

      t.references :leave_type, :null => false
      t.integer :status, :null => false, :default => 1 # New

      t.references :approver, :null => false

      t.date :date_from, :null => false
      t.boolean :half_day_from, :null => false, :default => false
      t.date :date_to, :null => false
      t.boolean :half_day_to, :null => false, :default => false

      t.boolean :unpaid, :null => false, :default => false

      t.text :comment
      
      # document (managed by paperclip)
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at

      t.timestamps
    end
    add_index :leave_requests, :identifier, :unique => true
    add_index :leave_requests, [:account_id, :employee_id]
    add_index :leave_requests, [:account_id, :leave_type_id]
  end

  def self.down
    drop_table :leave_requests
  end
end
