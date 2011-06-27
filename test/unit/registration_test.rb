require 'test_helper'

class RegistrationTest < ActiveSupport::TestCase

  test "fixture data valid" do
    registrations.each {|record| assert_valid record }
  end

  test "supplies dashboard url" do
    assert_equal false, registrations(:one).dashboard_url.nil?
  end

  test "supplies setup url" do
    assert_equal false, registrations(:one).setup_url.nil?
  end

end
