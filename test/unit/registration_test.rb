require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('registrations') {|key| assert_valid registrations(key) }
  end

end
