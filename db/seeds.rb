# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

puts "Seeding database..."

#
# Tenant Administrators
#
TenantAdmin.create([
  {
    :user_name => 'admin',
    :email => 'admin@example.com',
    :password => 'p@ssword123',
    :password_confirmation => 'p@ssword123'
  }
])

#
# Countries
#
open(File.expand_path('../countries', __FILE__)) do |countries|
  countries.read.each_line do |country|
    iso_code, title, currency_symbol, currency_code = country.chomp.split("|")
    Country.create!(
      :iso_code => iso_code.downcase,
      :title => title,
      :currency_symbol => currency_symbol,
      :currency_code => currency_code
    )
  end
end

puts "Loaded #{Country.count} countries"

#
# Country Holidays
#
Dir.chdir(File.expand_path('../', __FILE__)) do

  Dir.glob('holidays_*').each do |file|

    iso_code = file[file.length - 2, 2]
    country = Country.find_by_iso_code(iso_code.downcase)

    open(file) do |holidays|
      holidays.read.each_line do |holiday|
        entry_date, title = holiday.chomp.split("|")
        country.calendar_entries.build(:title => title, :entry_date => entry_date)
      end
    end

    country.save
    puts "Loaded #{country.calendar_entries.count} holidays for #{country}"

  end
end

#
# Partners
#

Partner.create([
  { :title => 'Human Faktor', :contact_name => 'Sales Department', :contact_email => 'info@human-faktor.com', :active => true }
])

#
# Subscriptions
#

load 'db/subscriptions.rb'
load 'db/subscriptions_by_country.rb'

# create a demo account

registration = Registration.create(
  :subdomain => 'demo',
  :title => 'Demo',
  :first_name => 'Demo',
  :last_name => 'User',
  :email => 'demo.user@example.com',
  :country => Country.find_by_iso_code('za')
)

account = AccountProvisioner.new(registration.id).perform()

account_setup = AccountSetup.new().tap do |setup|
  setup.admin_first_name = registration.first_name
  setup.admin_last_name = registration.last_name
  setup.admin_user_name = registration.user_name
  setup.admin_email = registration.email
  setup.admin_password = 'test123'
  setup.admin_password_confirmation = setup.admin_password

  setup.fixed_daily_hours = account.fixed_daily_hours
  setup.leave_cycle_start_date = Date.new(Date.today.year, 1, 1)

  LeaveType.for_each_leave_type_name do |leave_type_name|
    leave_type = account.send("leave_type_#{leave_type_name}")
    setup.send("#{leave_type_name}_leave_allowance=", leave_type.cycle_days_allowance)
  end

  setup.auth_token = account.auth_token
  setup.auth_token_confirmation = setup.auth_token
end

account_setup.save(account)
