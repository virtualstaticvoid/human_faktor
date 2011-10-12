class AddConstraintsToLeaveRequest < ActiveRecord::Migration
  def self.up
    change_table :leave_requests do |t|

      # constraints  
      t.boolean :constraint_exceeds_number_of_days_notice_required, :null => false, :default => false
      t.boolean :constraint_exceeds_minimum_number_of_days_per_request, :null => false, :default => false
      t.boolean :constraint_exceeds_maximum_number_of_days_per_request, :null => false, :default => false
      t.boolean :constraint_exceeds_leave_cycle_allowance, :null => false, :default => false
      t.boolean :constraint_exceeds_negative_leave_balance, :null => false, :default => false
      t.boolean :constraint_is_unscheduled, :null => false, :default => false
      t.boolean :constraint_is_adjacent, :null => false, :default => false
      t.boolean :constraint_requires_documentation, :null => false, :default => false

      # not used anymore!
      t.boolean :constraint_overlapping_request, :null => false, :default => false

      t.boolean :constraint_exceeds_maximum_future_date, :null => false, :default => false
      t.boolean :constraint_exceeds_maximum_back_date, :null => false, :default => false
      
      # overrides
      t.boolean :override_exceeds_number_of_days_notice_required, :null => false, :default => false
      t.boolean :override_exceeds_minimum_number_of_days_per_request, :null => false, :default => false
      t.boolean :override_exceeds_maximum_number_of_days_per_request, :null => false, :default => false
      t.boolean :override_exceeds_leave_cycle_allowance, :null => false, :default => false
      t.boolean :override_exceeds_negative_leave_balance, :null => false, :default => false
      t.boolean :override_is_unscheduled, :null => false, :default => false
      t.boolean :override_is_adjacent, :null => false, :default => false
      t.boolean :override_requires_documentation, :null => false, :default => false

      # not used anymore!
      t.boolean :override_overlapping_request, :null => false, :default => false

      t.boolean :override_exceeds_maximum_future_date, :null => false, :default => false
      t.boolean :override_exceeds_maximum_back_date, :null => false, :default => false

    end
  end

  def self.down
    change_table :leave_requests do |t|

      t.remove :override_exceeds_maximum_back_date
      t.remove :override_exceeds_maximum_future_date

      # not used anymore!
      t.remove :override_overlapping_request

      t.remove :override_requires_documentation
      t.remove :override_is_adjacent
      t.remove :override_is_unscheduled
      t.remove :override_exceeds_negative_leave_balance
      t.remove :override_exceeds_leave_cycle_allowance
      t.remove :override_exceeds_maximum_number_of_days_per_request
      t.remove :override_exceeds_minimum_number_of_days_per_request
      t.remove :override_exceeds_number_of_days_notice_required

      t.remove :constraint_exceeds_maximum_back_date
      t.remove :constraint_exceeds_maximum_future_date

      # not used anymore!
      t.remove :constraint_overlapping_request

      t.remove :constraint_requires_documentation
      t.remove :constraint_is_adjacent
      t.remove :constraint_is_unscheduled
      t.remove :constraint_exceeds_negative_leave_balance
      t.remove :constraint_exceeds_leave_cycle_allowance
      t.remove :constraint_exceeds_maximum_number_of_days_per_request
      t.remove :constraint_exceeds_minimum_number_of_days_per_request
      t.remove :constraint_exceeds_number_of_days_notice_required

    end
  end
end
