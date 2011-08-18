require 'test_helper'

class SupportMailerTest < ActionMailer::TestCase

  setup do
    @account = accounts(:one)
    @employee = employees(:admin)
    @registration = registrations(:one) 
  end
  
  test "registration" do
    mail = SupportMailer.registration(@registration)
    assert_equal "#{AppConfig.title} - New Registration!", mail.subject
    assert_equal [AppConfig.support_email], mail.to
    assert_equal [AppConfig.no_reply_email], mail.from
    #assert_match "Hi", mail.body.encoded
  end

  test "support_request" do
    mail = SupportMailer.support_request(@account, @employee, "Help Me Please!", "You better fix this!")
    assert_equal "#{AppConfig.title} - Support Request for #{@account.title} - Help Me Please!", mail.subject
    assert_equal [AppConfig.support_email], mail.to
    assert_equal [AppConfig.no_reply_email], mail.from
    #assert_match "Hi", mail.body.encoded
  end

end
