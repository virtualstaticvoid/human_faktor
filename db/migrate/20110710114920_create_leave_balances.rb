class CreateLeaveBalances < ActiveRecord::Migration
  def self.up
    create_table :leave_balances do |t|
      t.references :account, :null => false
      t.references :employee, :null => false
      t.references :leave_type, :null => false
      t.date :date_as_at, :null => false
      t.decimal :balance, :null => false

      t.timestamps
    end
    add_index :leave_balances, [:account_id, :employee_id, :leave_type_id, :date_as_at], :unique => true, :name => 'leave_balances_unique_index'
  end

  def self.down
    drop_table :leave_balances
  end
end
