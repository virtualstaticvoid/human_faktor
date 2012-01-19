class CreateLeaveRequestDays < ActiveRecord::Migration
  def self.up

    create_table :leave_request_days do |t|
      t.references :account, :null => false
      t.references :leave_request, :null => false
      t.date :leave_date, :null => false
      t.decimal :duration, :null => false, :default => 1.0
    end

    add_index :leave_request_days, [:account_id, :leave_request_id]
    add_index :leave_request_days, :leave_date

    # generate for existing records
    ActiveRecord::Base.transaction do

      LeaveRequest.all.each do |leave_request|
        LeaveRequestDay.create_for(leave_request)
      end
    
    end

  end

  def self.down
    drop_table :leave_request_days
  end
end
