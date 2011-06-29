require 'test_helper'

class LeaveTypeTest < ActiveSupport::TestCase

  test "fixture data valid" do
    leave_types.each {|record| assert_valid record }
  end

end
