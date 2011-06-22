class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :sequence, :null => false
      t.string :title, :null => false

      t.timestamps
    end
    add_index :subscriptions, :title, :unique => true
  end

  def self.down
    drop_table :subscriptions
  end
end
