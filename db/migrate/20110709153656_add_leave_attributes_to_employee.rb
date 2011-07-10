class AddLeaveAttributesToEmployee < ActiveRecord::Migration
  def self.up
    change_table :employees do |t|
      
      # leave policy overrides
      t.decimal :annual_leave_cycle_allocation
      t.decimal :educational_leave_cycle_allocation
      t.decimal :medical_leave_cycle_allocation
      t.decimal :maternity_leave_cycle_allocation
      t.decimal :compassionate_leave_cycle_allocation

      t.decimal :annual_leave_cycle_carry_over
      t.decimal :educational_leave_cycle_carry_over
      t.decimal :medical_leave_cycle_carry_over
      t.decimal :maternity_leave_cycle_carry_over
      t.decimal :compassionate_leave_cycle_carry_over
      
      # take on balances
      t.date :take_on_balance_as_at
      t.decimal :annual_leave_take_on_balance, :null => false, :default => 0
      t.decimal :educational_leave_take_on_balance, :null => false, :default => 0
      t.decimal :medical_leave_take_on_balance, :null => false, :default => 0
      t.decimal :maternity_leave_take_on_balance, :null => false, :default => 0
      t.decimal :compassionate_leave_take_on_balance, :null => false, :default => 0

      # additional information fields
      t.string :internal_reference, :length => 255
      
    end
  end

  def self.down
    change_table :employees do |t|
      
      t.remove :annual_leave_cycle_allocation
      t.remove :educational_leave_cycle_allocation
      t.remove :medical_leave_cycle_allocation
      t.remove :maternity_leave_cycle_allocation
      t.remove :compassionate_leave_cycle_allocation
      
      t.remove :annual_leave_cycle_carry_over
      t.remove :educational_leave_cycle_carry_over
      t.remove :medical_leave_cycle_carry_over
      t.remove :maternity_leave_cycle_carry_over
      t.remove :compassionate_leave_cycle_carry_over
      
      t.remove :take_on_balance_as_at
      t.remove :annual_leave_take_on_balance
      t.remove :educational_leave_take_on_balance
      t.remove :medical_leave_take_on_balance
      t.remove :maternity_leave_take_on_balance
      t.remove :compassionate_leave_take_on_balance

      t.remove :internal_reference

    end
  end
end
