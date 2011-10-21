## 
# Data for load tests
#

# NB: put reCAPTCHA into test mode!
Rack::Recaptcha.test_mode! :return => true

@registration = Registration.create(
  :subdomain => TokenHelper.friendly_token,
  :title => 'Load Test',
  :first_name => 'Load',
  :last_name => 'Test',
  :email => 'info@human-faktor.com'
)

@registration.save!

@account = AccountProvisioner.perform(@registration.id)
@account.update_attributes!(:active => true)


# load locations
@locations = []
@locations << @account.locations.build(:title => 'Location 1')
@locations << @account.locations.build(:title => 'Location 2')
@locations << @account.locations.build(:title => 'Location 3')
@locations << @account.locations.build(:title => 'Location 4')
@locations << @account.locations.build(:title => 'Location 5')

# load departments
@departments = []
@departments << @account.departments.build(:title => 'Department 1')
@departments << @account.departments.build(:title => 'Department 2')
@departments << @account.departments.build(:title => 'Department 3')
@departments << @account.departments.build(:title => 'Department 4')
@departments << @account.departments.build(:title => 'Department 5')

@account.save!

# load employees
@first_names = %w{Marg Jill
                  Jack John
                  Matthew Mark
                  Luke Samuel
                  Herbert Ernest
                  Chris Robin
                  Lucy Steve
                  Macy Gillian
                  Amy Clive
                  Henry Kim
                  Emily Dotty
                  Alfred Fred
                  Bernard Sam
                  Kitty Sky
                  Cloud Alice
                  Olly Jeremy
                  Paul Peter
                  Emma Tanya
                  Hannah Carina
                  Kirsen Kiara
                  Nadine Stan
                  Howard Jordan
                  Andrew Nicole
                  Megan Christine
                  Victoria Mervin
                  Jacob Michael
                  Richard Ben
                  Kevin Adam
                  Charlene Lauren
                  Sarah Jenny
                  Mary Derick}

@last_names = %w{Smith Jones 
                 Stevens Phillips
                 Peters Johnson
                 Jackson Henry
                 White Samson
                 Ackerman Russoux
                 Kendricks Adams
                 Parker Williams
                 Wood Young
                 Hill Michell
                 Ward Turner
                 Murphy Bell
                 Wright Harris
                 Barnes Brooks
                 Byran Watson
                 Roberts Evans 
                 Cooper Bailey
                 Nelson Moore
                 Rogers Scott
                 Price Lee}

@employees = []
@managers = []
@approvers = []

@admin = @account.employees.build(
    :user_name => "admin",
    :first_name => 'Joe',
    :last_name => "Admin",
    :email => "joe.admin@human-faktor.com",
    :role => :admin,
    :location => @locations[rand(@locations.length)],
    :department => @departments[rand(@departments.length)],
    :password => 'test123', :password_confirmation => 'test123',
    :active => true,
    :notify => true
  )

10.times do |i|
  @managers << @account.employees.build(
    :user_name => "jack.manager.#{i}",
    :first_name => 'Jack',
    :last_name => "Manager_#{i}",
    :email => "jack.manager.#{i}@human-faktor.com",
    :role => :manager,
    :location => @locations[rand(@locations.length)],
    :department => @departments[rand(@departments.length)],
    :approver => @admin,
    :password => 'test123', :password_confirmation => 'test123',
    :active => true,
    :notify => true
  )
end

@account.save!

10.times do |i|
  @approvers << @account.employees.build(
    :user_name => "jill.approver.#{i}",
    :first_name => 'Jill',
    :last_name => "Approver_#{i}",
    :email => "jill.approver.#{i}@human-faktor.com",
    :role => :approver,
    :location => @locations[rand(@locations.length)],
    :department => @departments[rand(@departments.length)],
    :approver => @managers[rand(@managers.length)],
    :password => 'test123', :password_confirmation => 'test123',
    :active => true,
    :notify => true
  )
end

@account.save!

for last_name in @last_names
  for first_name in @first_names
  
    @employees << @account.employees.build(
      :user_name => "#{first_name}.#{last_name}",
      :first_name => first_name,
      :last_name => last_name,
      :email => "#{first_name}.#{last_name}@human-faktor.com",
      :role => :employee,
      :location => @locations[rand(@locations.length)],
      :department => @departments[rand(@departments.length)],
      :approver => @approvers[rand(@approvers.length)],
      :password => 'test123', :password_confirmation => 'test123',
      :active => true
    )
  
  end
end

@account.save!

# load leave requests


puts ""
puts "Created account for load testing:"
puts "  http://test.lvh.me:3000/#{@account.subdomain}"
puts "  auth_token: #{@registration.auth_token}"
puts ""

