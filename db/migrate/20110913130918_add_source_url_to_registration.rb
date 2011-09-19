class AddSourceUrlToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :source_url, :text
  end

  def self.down
    remove_column :registrations, :source_url
  end
end
