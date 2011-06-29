class CreateLeaveTypes < ActiveRecord::Migration
  def self.up
    create_table :leave_types do |t|
      t.references :account, :null => false

      # maps to derived class of LeaveType::Base
      t.string :type, :null => false

      # leave cycle information
      t.date :cycle_start_date, :null => false
      t.integer :cycle_duration, :null => false
      t.integer :cycle_duration_unit, :null => false, :default => 3 # years
      t.decimal :cycle_days_allowance, :null => false
      t.decimal :cycle_days_carry_over, :null => false, :default => 0

      # capture permissions
      t.boolean :employee_capture_allowed, :null => false, :default => true
      t.boolean :approver_capture_allowed, :null => false, :default => true
      t.boolean :admin_capture_allowed, :null => false, :default => true

      # approval permissions
      t.boolean :approval_required, :null => false, :default => true

      # constraints
      t.boolean :requires_documentation, :null => false, :default => false
      t.integer :requires_documentation_after, :null => false, :default => 1
      t.boolean :unscheduled_leave_allowed, :null => false, :default => true
      t.integer :max_days_for_future_dated, :null => false, :default => 365
      t.integer :max_days_for_back_dated, :null => false, :default => 365
      t.decimal :min_days_per_single_request, :null => false, :default => 0.5
      t.decimal :max_days_per_single_request, :null => false, :default => 30
      t.decimal :required_days_notice, :null => false, :default => 1
      t.decimal :max_negative_balance, :null => false, :default => 0
      
      # display
      t.string :color, :null => false

      t.timestamps
    end
    add_index :leave_types, [:account_id, :type], :unique => true
  end

  def self.down
    drop_table :leave_types
  end
end
