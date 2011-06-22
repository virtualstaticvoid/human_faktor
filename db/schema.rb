# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110622101001) do

  create_table "countries", :force => true do |t|
    t.string   "iso_code",   :null => false
    t.string   "title",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["iso_code"], :name => "index_countries_on_iso_code", :unique => true
  add_index "countries", ["title"], :name => "index_countries_on_title", :unique => true

  create_table "partners", :force => true do |t|
    t.string   "title",                            :null => false
    t.string   "contact_name",                     :null => false
    t.string   "contact_email",                    :null => false
    t.boolean  "active",        :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "partners", ["title"], :name => "index_partners_on_title", :unique => true

  create_table "registrations", :force => true do |t|
    t.string   "identifier",                         :null => false
    t.string   "subdomain",                          :null => false
    t.string   "title",                              :null => false
    t.string   "email",                              :null => false
    t.integer  "country_id",                         :null => false
    t.integer  "subscription_id",                    :null => false
    t.integer  "partner_id"
    t.string   "auth_token",                         :null => false
    t.boolean  "active",          :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrations", ["auth_token"], :name => "index_registrations_on_auth_token", :unique => true
  add_index "registrations", ["identifier"], :name => "index_registrations_on_identifier", :unique => true
  add_index "registrations", ["subdomain"], :name => "index_registrations_on_subdomain", :unique => true

  create_table "subscriptions", :force => true do |t|
    t.integer  "sequence",                                :null => false
    t.string   "title",                                   :null => false
    t.text     "description",                             :null => false
    t.decimal  "price",                :default => 0.0,   :null => false
    t.integer  "max_employees",                           :null => false
    t.integer  "threshold",            :default => 0,     :null => false
    t.decimal  "price_over_threshold", :default => 0.0,   :null => false
    t.decimal  "duration",             :default => 1.0,   :null => false
    t.boolean  "active",               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["title"], :name => "index_subscriptions_on_title", :unique => true

end
