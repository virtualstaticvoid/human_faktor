class FixEmployeeEmailField < ActiveRecord::Migration
  def self.up
    change_column :employees, :email, :string, :null => true
  end

  def self.down
    change_column :employees, :email, :string, :null => false
  end
end
