class RegistrationsMailer < BaseMailer

  def completed(registration)  
    @registration = registration
    mail(
      :to => registration.email, 
      :bcc => AppConfig.support_email,
      :subject => "#{AppConfig.title} - Registration Completed"
    )  
  end  

end
