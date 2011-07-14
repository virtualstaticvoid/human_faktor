class AddReinstatementAttributesToLeaveRequest < ActiveRecord::Migration
  def self.up
    add_column :leave_requests, :reinstated_by_id, :integer
    add_column :leave_requests, :reinstated_at, :date
  end

  def self.down
    remove_column :leave_requests, :reinstated_at
    remove_column :leave_requests, :reinstated_by_id
  end
end
