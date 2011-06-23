class RegistrationsMailer < BaseMailer

  def completed(registration)  
    @registration = registration
    mail(:to => registration.email, :subject => "Welcome To #{AppConfig.title} - Registration Complete")  
  end  

end
