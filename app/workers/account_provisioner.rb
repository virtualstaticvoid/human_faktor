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
      :active => true
    )
    
    # subscription
    from_date = Date.today
    subscription = registration.subscription
    
    AccountSubscription.create(
      :account => account,
      :from_date => from_date,
      :to_date => from_date >> subscription.duration,
      :title => subscription.title, 
      :price => subscription.price, 
      :max_employees => subscription.max_employees,
      :threshold => subscription.threshold, 
      :price_over_threshold => subscription.price_over_threshold
    )
    
    # make the registration active
    registration.update_attribute(:active, true)

    # send welcome email
    RegistrationsMailer.completed(registration).deliver
    
    # return the newly created account
    account
    
  end
  
end
