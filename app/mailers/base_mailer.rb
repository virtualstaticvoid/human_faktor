class BaseMailer < ActionMailer::Base

  layout 'mailer'

  default :from => AppConfig.no_reply_email
  
end
