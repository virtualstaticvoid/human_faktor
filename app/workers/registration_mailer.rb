class RegistrationMailer
  @queue = :medium
  
  def self.perform(registration_id)
  
    registration = Registration.find(registration_id)
    
    # send welcome email
    RegistrationsMailer.completed(registration).deliver

  end
  
end
