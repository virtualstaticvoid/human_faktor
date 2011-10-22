class AddTrackbackToDemoRequests < ActiveRecord::Migration
  def self.up
    add_column :demo_requests, :trackback, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :demo_requests, :trackback
  end
end
