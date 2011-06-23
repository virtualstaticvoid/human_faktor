class AccountProvisioner
  @queue = :account_provisioner_queue
  
  def self.perform(registration_id)
  
    registration = Registration.find(registration_id)
    
    # TODO: create account etc...
    
    # make the registration active
    registration.update_attribute(:active, true)

    # send welcome email
    RegistrationsMailer.completed(registration).deliver
    
  end
  
end
