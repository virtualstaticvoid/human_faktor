require 'test_helper'

class LeaveRequestDayTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('leave_request_days') {|key| assert_valid leave_request_days(key), key }
  end

end
