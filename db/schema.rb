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

ActiveRecord::Schema.define(:version => 20110929120539) do

  create_table "account_subscriptions", :force => true do |t|
    t.integer  "account_id",                            :null => false
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
    t.string   "theme",             :default => "default", :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "auth_token",                               :null => false
    t.integer  "country_id",                               :null => false
    t.integer  "location_id"
    t.integer  "department_id"
    t.integer  "fixed_daily_hours", :default => 8,         :null => false
    t.boolean  "active",            :default => false,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["subdomain"], :name => "index_accounts_on_subdomain", :unique => true

  create_table "bulk_upload_stages", :force => true do |t|
    t.integer "bulk_upload_id",                                  :null => false
    t.integer "line_number",                  :default => 0,     :null => false
    t.boolean "selected",                     :default => false, :null => false
    t.text    "messages"
    t.string  "reference"
    t.string  "title"
    t.string  "first_name"
    t.string  "middle_name"
    t.string  "last_name"
    t.string  "gender"
    t.string  "email"
    t.string  "telephone"
    t.string  "mobile"
    t.string  "designation"
    t.string  "start_date"
    t.string  "location_name"
    t.string  "department_name"
    t.string  "approver_first_and_last_name"
    t.string  "role"
    t.string  "take_on_balance_as_at"
    t.string  "annual_leave_take_on"
    t.string  "educational_leave_take_on"
    t.string  "medical_leave_take_on"
    t.string  "compassionate_leave_take_on"
    t.string  "maternity_leave_take_on"
  end

  add_index "bulk_upload_stages", ["bulk_upload_id"], :name => "index_bulk_upload_stages_on_bulk_upload_id"

  create_table "bulk_uploads", :force => true do |t|
    t.integer  "account_id",                      :null => false
    t.integer  "status",           :default => 0, :null => false
    t.string   "comment"
    t.text     "messages"
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bulk_uploads", ["account_id"], :name => "index_bulk_uploads_on_account_id"

  create_table "calendar_entries", :force => true do |t|
    t.integer  "country_id", :null => false
    t.string   "title",      :null => false
    t.date     "entry_date", :null => false
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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "departments", :force => true do |t|
    t.integer  "account_id", :null => false
    t.string   "title",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["account_id", "title"], :name => "index_departments_on_account_id_and_title", :unique => true

  create_table "employees", :force => true do |t|
    t.integer  "account_id",                                                                  :null => false
    t.string   "identifier",                                                                  :null => false
    t.string   "user_name",                                                                   :null => false
    t.string   "email",                                               :default => "",         :null => false
    t.string   "encrypted_password",                   :limit => 128, :default => "",         :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                                     :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "title"
    t.string   "first_name",                                                                  :null => false
    t.string   "middle_name"
    t.string   "last_name",                                                                   :null => false
    t.integer  "gender"
    t.string   "designation"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "location_id"
    t.integer  "department_id"
    t.integer  "approver_id"
    t.string   "role",                                                :default => "employee", :null => false
    t.integer  "fixed_daily_hours",                                   :default => 8,          :null => false
    t.boolean  "active",                                              :default => false,      :null => false
    t.boolean  "notify",                                              :default => false,      :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "annual_leave_cycle_allocation"
    t.decimal  "educational_leave_cycle_allocation"
    t.decimal  "medical_leave_cycle_allocation"
    t.decimal  "maternity_leave_cycle_allocation"
    t.decimal  "compassionate_leave_cycle_allocation"
    t.decimal  "annual_leave_cycle_carry_over"
    t.decimal  "educational_leave_cycle_carry_over"
    t.decimal  "medical_leave_cycle_carry_over"
    t.decimal  "maternity_leave_cycle_carry_over"
    t.decimal  "compassionate_leave_cycle_carry_over"
    t.date     "take_on_balance_as_at"
    t.decimal  "annual_leave_take_on_balance",                        :default => 0.0,        :null => false
    t.decimal  "educational_leave_take_on_balance",                   :default => 0.0,        :null => false
    t.decimal  "medical_leave_take_on_balance",                       :default => 0.0,        :null => false
    t.decimal  "maternity_leave_take_on_balance",                     :default => 0.0,        :null => false
    t.decimal  "compassionate_leave_take_on_balance",                 :default => 0.0,        :null => false
    t.string   "internal_reference"
    t.string   "telephone"
    t.string   "telephone_extension"
    t.string   "cellphone"
  end

  add_index "employees", ["account_id", "user_name"], :name => "index_employees_on_account_id_and_user_name", :unique => true
  add_index "employees", ["authentication_token"], :name => "index_employees_on_authentication_token", :unique => true
  add_index "employees", ["identifier"], :name => "index_employees_on_identifier", :unique => true
  add_index "employees", ["reset_password_token"], :name => "index_employees_on_reset_password_token", :unique => true
  add_index "employees", ["unlock_token"], :name => "index_employees_on_unlock_token", :unique => true

  create_table "leave_balances", :force => true do |t|
    t.integer  "account_id",    :null => false
    t.integer  "employee_id",   :null => false
    t.integer  "leave_type_id", :null => false
    t.date     "date_as_at",    :null => false
    t.decimal  "balance",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leave_balances", ["account_id", "employee_id", "leave_type_id", "date_as_at"], :name => "leave_balances_unique_index", :unique => true

  create_table "leave_requests", :force => true do |t|
    t.integer  "account_id",                                                               :null => false
    t.string   "identifier",                                                               :null => false
    t.integer  "employee_id",                                                              :null => false
    t.integer  "leave_type_id",                                                            :null => false
    t.integer  "status",                                                :default => 1,     :null => false
    t.integer  "approver_id",                                                              :null => false
    t.date     "date_from",                                                                :null => false
    t.boolean  "half_day_from",                                         :default => false, :null => false
    t.date     "date_to",                                                                  :null => false
    t.boolean  "half_day_to",                                           :default => false, :null => false
    t.boolean  "unpaid",                                                :default => false, :null => false
    t.text     "comment"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "constraint_exceeds_number_of_days_notice_required",     :default => false, :null => false
    t.boolean  "constraint_exceeds_minimum_number_of_days_per_request", :default => false, :null => false
    t.boolean  "constraint_exceeds_maximum_number_of_days_per_request", :default => false, :null => false
    t.boolean  "constraint_exceeds_leave_cycle_allowance",              :default => false, :null => false
    t.boolean  "constraint_exceeds_negative_leave_balance",             :default => false, :null => false
    t.boolean  "constraint_is_unscheduled",                             :default => false, :null => false
    t.boolean  "constraint_is_adjacent",                                :default => false, :null => false
    t.boolean  "constraint_requires_documentation",                     :default => false, :null => false
    t.boolean  "constraint_overlapping_request",                        :default => false, :null => false
    t.boolean  "constraint_exceeds_maximum_future_date",                :default => false, :null => false
    t.boolean  "constraint_exceeds_maximum_back_date",                  :default => false, :null => false
    t.boolean  "override_exceeds_number_of_days_notice_required",       :default => false, :null => false
    t.boolean  "override_exceeds_minimum_number_of_days_per_request",   :default => false, :null => false
    t.boolean  "override_exceeds_maximum_number_of_days_per_request",   :default => false, :null => false
    t.boolean  "override_exceeds_leave_cycle_allowance",                :default => false, :null => false
    t.boolean  "override_exceeds_negative_leave_balance",               :default => false, :null => false
    t.boolean  "override_is_unscheduled",                               :default => false, :null => false
    t.boolean  "override_is_adjacent",                                  :default => false, :null => false
    t.boolean  "override_requires_documentation",                       :default => false, :null => false
    t.boolean  "override_overlapping_request",                          :default => false, :null => false
    t.boolean  "override_exceeds_maximum_future_date",                  :default => false, :null => false
    t.boolean  "override_exceeds_maximum_back_date",                    :default => false, :null => false
    t.boolean  "captured",                                              :default => false, :null => false
    t.integer  "approved_declined_by_id"
    t.datetime "approved_declined_at"
    t.text     "approver_comment"
    t.datetime "cancelled_at"
    t.integer  "cancelled_by_id"
    t.decimal  "duration"
    t.integer  "reinstated_by_id"
    t.date     "reinstated_at"
    t.integer  "captured_by_id"
  end

  add_index "leave_requests", ["account_id", "employee_id"], :name => "index_leave_requests_on_account_id_and_employee_id"
  add_index "leave_requests", ["account_id", "leave_type_id"], :name => "index_leave_requests_on_account_id_and_leave_type_id"
  add_index "leave_requests", ["identifier"], :name => "index_leave_requests_on_identifier", :unique => true

  create_table "leave_types", :force => true do |t|
    t.integer  "account_id",                                      :null => false
    t.string   "type",                                            :null => false
    t.date     "cycle_start_date",                                :null => false
    t.integer  "cycle_duration",                                  :null => false
    t.integer  "cycle_duration_unit",          :default => 3,     :null => false
    t.decimal  "cycle_days_allowance",                            :null => false
    t.decimal  "cycle_days_carry_over",        :default => 0.0,   :null => false
    t.boolean  "employee_capture_allowed",     :default => true,  :null => false
    t.boolean  "approver_capture_allowed",     :default => true,  :null => false
    t.boolean  "admin_capture_allowed",        :default => true,  :null => false
    t.boolean  "approval_required",            :default => true,  :null => false
    t.boolean  "requires_documentation",       :default => false, :null => false
    t.integer  "requires_documentation_after", :default => 1,     :null => false
    t.boolean  "unscheduled_leave_allowed",    :default => true,  :null => false
    t.integer  "max_days_for_future_dated",    :default => 365,   :null => false
    t.integer  "max_days_for_back_dated",      :default => 365,   :null => false
    t.decimal  "min_days_per_single_request",  :default => 0.5,   :null => false
    t.decimal  "max_days_per_single_request",  :default => 30.0,  :null => false
    t.decimal  "required_days_notice",         :default => 1.0,   :null => false
    t.decimal  "max_negative_balance",         :default => 0.0,   :null => false
    t.string   "color",                                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order",                :default => 0,     :null => false
  end

  add_index "leave_types", ["account_id", "type"], :name => "index_leave_types_on_account_id_and_type", :unique => true

  create_table "locations", :force => true do |t|
    t.integer  "account_id", :null => false
    t.string   "title",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["account_id", "title"], :name => "index_locations_on_account_id_and_title", :unique => true

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
    t.string   "first_name",                         :null => false
    t.string   "last_name",                          :null => false
    t.string   "email",                              :null => false
    t.boolean  "active",          :default => false, :null => false
    t.string   "auth_token",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "source_url"
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
