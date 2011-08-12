class AddDisplayOrderToLeaveType < ActiveRecord::Migration
  def self.up
    add_column :leave_types, :display_order, :integer, :null => false, :default => 0
    
    # update existing leave types
    display_order = 0
    LeaveType.for_each_leave_type do |leave_type|
      LeaveType.where(:type => leave_type.name).update_all ["display_order = ?", display_order]
      display_order += 1
    end
    
  end

  def self.down
    remove_column :leave_types, :display_order
  end
end
