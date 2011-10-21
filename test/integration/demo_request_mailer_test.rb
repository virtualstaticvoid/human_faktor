require 'test_helper'

class DemoRequestMailerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should perform work" do
    demo_request = demo_requests(:one)
    
    DemoRequestMailer.new(demo_request.id).perform()

    # TODO: assert that an email was sent
    assert !ActionMailer::Base.deliveries.empty?

  end

end
