class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations do |t|
    
      t.string :identifier, :null => false
      t.string :subdomain, :null => false, :length => 255
      t.string :title, :null => false, :length => 255

      t.references :country, :null => false
      t.references :subscription, :null => false
      t.references :partner
      
      # contact details
      t.string :name, :null => false, :length => 255
      t.string :email, :null => false

      t.boolean :active, :null => false, :default => false
  
      # access token for initial setup
      t.string :auth_token, :null => false

      t.timestamps
    end
    
    add_index :registrations, :identifier, :unique => true
    add_index :registrations, :subdomain, :unique => true
    add_index :registrations, :auth_token, :unique => true
  end

  def self.down
    drop_table :registrations
  end
end
