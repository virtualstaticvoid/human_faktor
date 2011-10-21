require 'test_helper'

class DemoRequestsMailerTest < ActionMailer::TestCase

  setup do
    @demo_request = demo_requests(:one) 
  end
  
  test "request" do
    mail = DemoRequestsMailer.request_demo(@demo_request)
    assert_equal "#{AppConfig.title} - Demo Request", mail.subject
    assert_equal [@demo_request.email], mail.to
    assert_equal [AppConfig.no_reply_email], mail.from
    #assert_match "Hi", mail.body.encoded
  end

end
