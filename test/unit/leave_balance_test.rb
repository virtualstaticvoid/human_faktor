require 'test_helper'

class LeaveBalanceTest < ActiveSupport::TestCase

  test "fixture data valid" do
    leave_balances.each {|record| assert_valid record }
  end

end
