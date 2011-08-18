class SupportMailer < BaseMailer

  def registration(registration)
    @registration = registration
    mail(
      :to => AppConfig.support_email, 
      :subject => "#{AppConfig.title} - New Registration!"
    )  
  end  

  def support_request(account, employee, subject, message)
    @account = account
    @employee = employee
    @message = message.html_safe
    mail(
      :to => AppConfig.support_email, 
      :subject => "#{AppConfig.title} - Support Request for #{account.title} - #{subject}"
    )  
  end  

end
