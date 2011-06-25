class BaseMailer < ActionMailer::Base

  ActionMailer::Base.default_url_options[:host] = AppConfig.domain

  default :from => AppConfig.no_reply_email
  
end
