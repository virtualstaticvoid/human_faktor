require 'test_helper'

class LeaveRequestTest < ActiveSupport::TestCase

  test "fixture data valid" do
    leave_requests.each {|record| assert_valid record }
  end

end
