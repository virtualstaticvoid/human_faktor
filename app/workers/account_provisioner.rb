require 'date'

class AccountProvisioner
  @queue = :account_provisioner_queue
  
  def self.perform(registration_id)
  
    registration = Registration.find(registration_id)
    
    # create account
    account = Account.create(
      :subdomain => registration.subdomain,
      :title => registration.title,
      :country => registration.country,
      :partner => registration.partner,
      :theme => AppConfig.default_theme,
      :auth_token => registration.auth_token,
      :active => false
    )
    
    # subscription
    subscription = registration.subscription

    #  calculate the start and end dates of the subscription
    from_date = Date.today
    to_date = Date.new(from_date.year, from_date.month + 1, 1) >> subscription.duration
    
    AccountSubscription.create(
      :account => account,
      :from_date => from_date,
      :to_date => to_date,
      :title => subscription.title, 
      :price => subscription.price, 
      :max_employees => subscription.max_employees,
      :threshold => subscription.threshold, 
      :price_over_threshold => subscription.price_over_threshold
    )
    
    # default location and department
    account.locations.build(:title => 'Default')
    account.departments.build(:title => 'Default')
    
    # make the registration active
    registration.update_attribute(:active, true)

    # send welcome email
    RegistrationsMailer.completed(registration).deliver
    
    # return the newly created account
    account
    
  end
  
end
