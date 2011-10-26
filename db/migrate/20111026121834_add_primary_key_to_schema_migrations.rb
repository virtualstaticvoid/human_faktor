class AddPrimaryKeyToSchemaMigrations < ActiveRecord::Migration
  def self.up
    add_index :schema_migrations, :version, :unique => true
  end

  def self.down
    remove_index :schema_migrations, :version
  end
end