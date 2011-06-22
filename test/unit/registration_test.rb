require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase

  test "fixture data valid" do
    registrations.each {|record| assert_valid record }
  end

end
