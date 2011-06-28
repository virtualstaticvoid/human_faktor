class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|

      t.string :identifier, :null => false
      t.string :subdomain, :null => false, :length => 255
      t.string :title, :null => false, :length => 255
      
      t.references :country, :null => false
      t.references :partner

      t.string :theme, :null => false, :default => 'default'
      t.integer :fixed_daily_hours, :null => false, :default => 8
      t.boolean :active, :null => false, :default => false

      # logo (managed by paperclip)
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.datetime :logo_updated_at

      # access token for initial setup
      t.string :auth_token, :null => false

      t.timestamps
    end
    add_index :accounts, :subdomain, :unique => true
  end

  def self.down
    drop_table :accounts
  end
end
