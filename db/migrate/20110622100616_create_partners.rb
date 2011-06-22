class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string :title, :null => false

      t.timestamps
    end
    add_index :partners, :title, :unique => true
  end

  def self.down
    drop_table :partners
  end
end
