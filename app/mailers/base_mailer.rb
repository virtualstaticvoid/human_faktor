class BaseMailer < ActionMailer::Base

  layout 'mailer'

  add_template_helper(ApplicationHelper)

  default :from => AppConfig.no_reply_email

end
