class BaseMailer < ActionMailer::Base

  default :from => AppConfig.no_reply_email
  
end
