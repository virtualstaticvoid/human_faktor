class DemoRequestsMailer < BaseMailer

  def request_demo(demo_request)
    @demo_request = demo_request
    @demo_auth_token = h.demo_auth_token
    mail(
      :to => demo_request.email, 
      :bcc => AppConfig.support_email,
      :subject => "#{AppConfig.title} - Demo Request"
    )  
  end

end
