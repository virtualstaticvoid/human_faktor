class RegistrationMailer < Struct.new(:registration_id)
  
  def perform()
  
    registration = Registration.find(registration_id)
    
    # send welcome email
    RegistrationsMailer.completed(registration).deliver
    
    # send email to support
    SupportMailer.registration(registration).deliver

  end
  
end
