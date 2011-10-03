class CreateBulkUploadStages < ActiveRecord::Migration
  def self.up
    create_table :bulk_upload_stages do |t|
      t.references :bulk_upload, :null => false
      
      #
      # NB: no constraints or validations for the following fields
      #
      
      t.string :reference
      
      t.string :title
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :gender
      
      t.string :email
      t.string :telephone
      t.string :mobile
      
      t.string :designation
      t.string :start_date
      t.string :location_name
      t.string :department_name
      t.string :approver_first_and_last_name
      t.string :role
      
      t.string :take_on_balance_as_at
      t.string :annual_leave_take_on
      t.string :educational_leave_take_on
      t.string :medical_leave_take_on
      t.string :compassionate_leave_take_on
      t.string :maternity_leave_take_on

    end
    add_index :bulk_upload_stages, :bulk_upload_id
  end

  def self.down
    drop_table :bulk_upload_stages
  end
end
