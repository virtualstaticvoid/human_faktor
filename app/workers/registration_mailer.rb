class RegistrationMailer < Struct.new(:registration_id)
  
  def perform()
  
    registration = Registration.find(registration_id)
    
    # send welcome email
    RegistrationsMailer.completed(registration).deliver
    
  end
  
end
