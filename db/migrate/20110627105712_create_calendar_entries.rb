class CreateCalendarEntries < ActiveRecord::Migration
  def self.up
    create_table :calendar_entries do |t|
      t.references :country, :null => false
      t.string :title, :null => false
      t.date :entry_date, :null => false

      t.timestamps
    end
    add_index :calendar_entries, [:country_id, :entry_date]
  end

  def self.down
    drop_table :calendar_entries
  end
end
