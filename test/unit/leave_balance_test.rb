require 'test_helper'

class LeaveBalanceTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('leave_balances') {|key| assert_valid leave_balances(key) }
  end

end
