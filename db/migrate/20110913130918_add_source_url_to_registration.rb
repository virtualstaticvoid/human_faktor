class AddSourceUrlToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :source_url, :string
  end

  def self.down
    remove_column :registrations, :source_url
  end
end
