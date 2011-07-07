# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HumanFaktor::Application.initialize!

# Further configuration which uses AppConfig

# mailer host
ActionMailer::Base.default_url_options[:host] = "#{AppConfig.subdomain}.#{AppConfig.domain}"

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

