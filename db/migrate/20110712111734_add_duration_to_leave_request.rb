class AddDurationToLeaveRequest < ActiveRecord::Migration
  def self.up
    add_column :leave_requests, :duration, :decimal
  end

  def self.down
    remove_column :leave_requests, :duration
  end
end
