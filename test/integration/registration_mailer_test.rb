require 'test_helper'

class RegistrationMailerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should perform work" do
    registration = registrations(:one)
    
    RegistrationMailer.perform(registration.id)

    # TODO: assert that an email was sent
    assert !ActionMailer::Base.deliveries.empty?

  end

end
