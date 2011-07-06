class AddControlsToLeaveRequest < ActiveRecord::Migration
  def self.up
    change_table :leave_requests do |t|
      t.boolean :captured, :null => false, :default => false
      t.references :approved_declined_by
      t.datetime :approved_declined_at
      t.text :approver_comment
      t.datetime :cancelled_at
    end
  end

  def self.down
    change_table :leave_requests do |t|
      t.remove :captured
      t.remove :approved_declined_by_id
      t.remove :approved_declined_at
      t.remove :approver_comment
      t.remove :cancelled_at
    end
  end
end
