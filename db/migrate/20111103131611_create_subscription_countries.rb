class CreateSubscriptionCountries < ActiveRecord::Migration
  def self.up
    create_table :subscription_countries do |t|
      t.integer :subscription_id, :null => false
      t.integer :country_id, :null => false
      t.decimal :price, :null => false, :default => 0
      t.decimal :price_over_threshold, :null => false, :default => 0

      t.timestamps
    end
    add_index :subscription_countries, [:subscription_id, :country_id], :unique => true
  end

  def self.down
    drop_table :subscription_countries
  end
end
