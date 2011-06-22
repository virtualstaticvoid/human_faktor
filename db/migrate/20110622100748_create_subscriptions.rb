class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :sequence, :null => false
      t.string :title, :null => false, :length => 255
      t.text :description, :null => false
      t.decimal :price, :null => false, :default => 0
      t.integer :max_employees, :null => false
      t.integer :threshold, :null => false, :default => 0
      t.decimal :price_over_threshold, :null => false, :default => 0
      t.decimal :duration, :null => false, :default => 1
      t.boolean :active, :null => false, :default => false

      t.timestamps
    end
    add_index :subscriptions, :title, :unique => true
  end

  def self.down
    drop_table :subscriptions
  end
end
