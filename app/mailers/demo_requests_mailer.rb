class DemoRequestsMailer < BaseMailer

  def request_demo(demo_request)
    @demo_request = demo_request
    @demo_auth_token = demo_auth_token
    mail(
      :to => demo_request.email, 
      :subject => "#{AppConfig.title} - Demo Request"
    )  
  end

  private

  # NNB: this demo data must exist, and is created in the seeds
  def demo_auth_token
    demo_account = Account.find_by_subdomain('demo')
    demo_user = demo_account.employees.find_by_user_name('demo.user')
    demo_user.ensure_authentication_token!
    demo_user.authentication_token
  end

end
