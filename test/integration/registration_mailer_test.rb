require 'test_helper'

class RegistrationMailerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should perform work" do
    registration = registrations(:one)
    
    RegistrationMailer.perform(registration.id)

    # assert that 2 emails were sent

  end

end
