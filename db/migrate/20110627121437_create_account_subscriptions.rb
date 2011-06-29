class CreateAccountSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :account_subscriptions do |t|
      t.references :account, :null => false

      # validity period
      t.date :from_date, :null => false
      t.date :to_date, :null => false

      # subscription details
      t.string :title, :null => false, :length => 255
      t.decimal :price, :null => false, :default => 0
      t.integer :max_employees, :null => false
      t.integer :threshold, :null => false, :default => 0
      t.decimal :price_over_threshold, :null => false, :default => 0

      t.timestamps
    end
    add_index :account_subscriptions, :account_id
  end

  def self.down
    drop_table :account_subscriptions
  end
end
