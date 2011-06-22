class AccountProvisioner
  @queue = :account_provisioner_queue
  
  def self.perform(registration_id)
    registration = Registration.find(registration_id)
    
    # TODO: create account etc...
    
    registration.update_attribute(:active, true)
  end
  
end
