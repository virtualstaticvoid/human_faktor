class CreateDemoRequests < ActiveRecord::Migration
  def self.up
    create_table :demo_requests do |t|
      t.string :identifier, :null => false

      # contact details
      t.string :first_name, :null => false, :length => 255
      t.string :last_name, :null => false, :length => 255
      t.string :email, :null => false

      t.references :country, :null => false

      t.timestamps
    end
    add_index :demo_requests, :identifier, :unique => true
  end

  def self.down
    drop_table :demo_requests
  end
end
