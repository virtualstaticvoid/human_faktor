class BaseMailer < ActionMailer::Base

  # configure mailer for SMTP in development
  if Rails.env.development?
    ActionMailer::Base.smtp_settings = {  
      :address              => AppConfig.smtp_server,  
      :port                 => AppConfig.smtp_port,  
      :domain               => AppConfig.smtp_domain,  
      :authentication       => :plain,  
      :user_name            => AppConfig.smtp_user_name,  
      :password             => AppConfig.smtp_password,  
      :enable_starttls_auto => false
    }
  end

  ActionMailer::Base.default_url_options[:host] = "#{AppConfig.subdomain}.#{AppConfig.domain}"

  default :from => AppConfig.no_reply_email
  
end
