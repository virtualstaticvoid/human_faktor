class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :iso_code, :null => false
      t.string :title, :null => false

      t.timestamps
    end
    add_index :countries, :iso_code, :unique => true
    add_index :countries, :title, :unique => true
  end

  def self.down
    drop_table :countries
  end
end
