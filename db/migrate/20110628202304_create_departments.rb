class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.references :account, :null => false
      t.string :title, :null => false, :length => 255

      t.timestamps
    end
    add_index :departments, [:account_id, :title], :unique => true
  end

  def self.down
    drop_table :departments
  end
end

