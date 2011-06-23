require 'test_helper'

class RegistrationsMailerTest < ActionMailer::TestCase

  setup do
    @registration = registrations(:one) 
  end
  
  test "completed" do
    mail = RegistrationsMailer.completed(@registration)
    assert_equal "Welcome to #{AppConfig.title} - Registration Completed", mail.subject
    assert_equal [@registration.email], mail.to
    assert_equal [AppConfig.no_reply_email], mail.from
    #assert_match "Hi", mail.body.encoded
  end

end
