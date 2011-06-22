class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string :title, :null => false, :length => 255
      t.string :contact_name, :null => false, :length => 255
      t.string :contact_email, :null => false, :length => 255
      t.boolean :active, :null => false, :default => false

      t.timestamps
    end
    add_index :partners, :title, :unique => true
  end

  def self.down
    drop_table :partners
  end
end
