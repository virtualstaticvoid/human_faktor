class AddCancelledByToLeaveRequest < ActiveRecord::Migration
  def self.up
    add_column :leave_requests, :cancelled_by_id, :integer
  end

  def self.down
    remove_column :leave_requests, :cancelled_by_id
  end
end
