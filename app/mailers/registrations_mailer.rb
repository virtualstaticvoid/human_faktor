class RegistrationsMailer < BaseMailer

  def completed(registration)  
    @registration = registration
    mail(:to => registration.email, :subject => "Welcome to #{AppConfig.title} - Registration Complete")  
  end  

end
