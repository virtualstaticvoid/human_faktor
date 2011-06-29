class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.references :account, :null => false
      t.string :title, :null => false, :length => 255

      t.timestamps
    end
    add_index :locations, [:account_id, :title], :unique => true
  end

  def self.down
    drop_table :locations
  end
end

