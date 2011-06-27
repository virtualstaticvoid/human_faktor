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

ActiveRecord::Schema.define(:version => 20110627121437) do

  create_table "account_subscriptions", :force => true do |t|
    t.integer  "account_id"
    t.date     "from_date",                             :null => false
    t.date     "to_date",                               :null => false
    t.string   "title",                                 :null => false
    t.decimal  "price",                :default => 0.0, :null => false
    t.integer  "max_employees",                         :null => false
    t.integer  "threshold",            :default => 0,   :null => false
    t.decimal  "price_over_threshold", :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_subscriptions", ["account_id"], :name => "index_account_subscriptions_on_account_id"

  create_table "accounts", :force => true do |t|
    t.string   "identifier",                               :null => false
    t.string   "subdomain",                                :null => false
    t.string   "title",                                    :null => false
    t.integer  "country_id",                               :null => false
    t.integer  "partner_id"
    t.string   "theme",             :default => "default", :null => false
    t.integer  "fixed_daily_hours", :default => 8,         :null => false
    t.boolean  "active",            :default => false,     :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["subdomain"], :name => "index_accounts_on_subdomain", :unique => true

  create_table "calendar_entries", :force => true do |t|
    t.integer  "country_id"
    t.string   "title"
    t.date     "entry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "calendar_entries", ["country_id", "entry_date"], :name => "index_calendar_entries_on_country_id_and_entry_date"

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
    t.integer  "country_id",                         :null => false
    t.integer  "subscription_id",                    :null => false
    t.integer  "partner_id"
    t.string   "name",                               :null => false
    t.string   "email",                              :null => false
    t.boolean  "active",          :default => false, :null => false
    t.string   "auth_token",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registrations", ["auth_token"], :name => "index_registrations_on_auth_token", :unique => true
  add_index "registrations", ["identifier"], :name => "index_registrations_on_identifier", :unique => true
  add_index "registrations", ["subdomain"], :name => "index_registrations_on_subdomain", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

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
