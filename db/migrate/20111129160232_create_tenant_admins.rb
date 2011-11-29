class CreateTenantAdmins < ActiveRecord::Migration
  def self.up
    create_table(:tenant_admins) do |t|
    
      # identifiers
      t.string :identifier, :null => false
      t.string :user_name, :null => false, :length => 50
      t.string :email, :null => false, :length => 255
      
      # authentication
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable

      t.boolean :active, :null => false, :default => true

      t.timestamps
    end

    add_index :tenant_admins, :identifier, :unique => true
    add_index :tenant_admins, :user_name, :unique => true
    add_index :tenant_admins, :reset_password_token, :unique => true
    add_index :tenant_admins, :unlock_token, :unique => true
    add_index :tenant_admins, :authentication_token, :unique => true
  end

  def self.down
    drop_table :tenant_admins
  end
end