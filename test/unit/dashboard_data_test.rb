require 'test_helper'

class DashboardDataTest < ActiveSupport::TestCase

  setup do
    @dashboard = DashboardData.new(accounts(:one), employees(:admin))
  end

  test "should get pending leave requests" do
    assert @dashboard.pending_leave_requests
  end
  
  test "should get pending staff leave requests" do
    assert @dashboard.pending_staff_leave_requests
  end
  
  test "should get recent leave requests" do
    assert @dashboard.recent_leave_requests
  end
  
  test "should get leave requests requiring documentation" do
    assert @dashboard.leave_requests_requiring_documentation
  end
  
  test "should get staff leave requests requiring documentation" do
    assert @dashboard.staff_leave_requests_requiring_documentation
  end
  
  test "should provide annual leave type" do
    assert @dashboard.annual_leave_type
  end

end
