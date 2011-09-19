require 'test_helper'

class DashboardDataTest < ActiveSupport::TestCase

  setup do
    @dashboard = DashboardData.new(accounts(:one), employees(:one))
  end

  test "should have pending leave requests" do
    assert @dashboard.pending_leave_requests
  end

end
