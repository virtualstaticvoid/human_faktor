require 'test_helper'

class RegistrationSystemMailerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should perform work" do
    registration = registrations(:one)
    
    RegistrationSystemMailer.new(registration.id).perform()

    # TODO: assert that an email was sent
    assert !ActionMailer::Base.deliveries.empty?

  end

end
