class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :iso_code, :null => false, :length => 2
      t.string :title, :null => false, :length => 255

      t.timestamps
    end
    add_index :countries, :iso_code, :unique => true
    add_index :countries, :title, :unique => true
  end

  def self.down
    drop_table :countries
  end
end
