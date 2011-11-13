class RegistrationSystemMailer < Struct.new(:registration_id)
  
  def perform()
  
    registration = Registration.find(registration_id)
    
    # send email to support
    SupportMailer.registration(registration).deliver

  end
  
end
