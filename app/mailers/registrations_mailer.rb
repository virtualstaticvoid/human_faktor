class RegistrationsMailer < BaseMailer

  def completed(registration)  
    @registration = registration
    mail(:to => registration.email, :subject => "#{AppConfig.title} - Registration Completed")  
  end  

end
