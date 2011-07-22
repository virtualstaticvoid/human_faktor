class AddContactDetailsToEmployee < ActiveRecord::Migration
  def self.up
    change_table :employees do |t|
      t.string :telephone, :length => 20
      t.string :telephone_extension, :length => 10
      t.string :cellphone, :length => 20
    end
  end

  def self.down
    change_table :employees do |t|
      t.remove :cellphone
      t.remove :telephone_extension
      t.remove :telephone
    end
  end
end
