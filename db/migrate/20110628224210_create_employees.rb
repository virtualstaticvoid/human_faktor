class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table(:employees) do |t|
      t.references :account, :null => false
    
      # identifiers
      t.string :identifier, :null => false
      t.string :user_name, :null => false, :length => 50
      t.string :email, :length => 255     # may be null for employees w/o computers
      
      # authentication
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable

      # personal information
      t.string :title, :length => 20
      t.string :first_name, :null => false, :length => 100
      t.string :middle_name, :length => 100
      t.string :last_name,  :null => false, :length => 100
      t.integer :gender

      # job information
      t.string :designation, :length => 255
      t.date :start_date
      t.date :end_date
      t.references :location
      t.references :department
      t.integer :approver_id    # references employee

      # system settings
      t.string :role, :null => false, :default => 'employee'
      t.integer :fixed_daily_hours, :null => false, :default => 8
      t.boolean :active, :null => false, :default => false

      # notifications      
      t.boolean :notify, :null => false, :default => false

      # avatar for employee
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at

      t.timestamps
    end

    add_index :employees, :identifier, :unique => true
    add_index :employees, [:account_id, :user_name], :unique => true
    add_index :employees, :reset_password_token, :unique => true
    add_index :employees, :unlock_token, :unique => true
    add_index :employees, :authentication_token, :unique => true
  end

  def self.down
    drop_table :employees
  end
end
