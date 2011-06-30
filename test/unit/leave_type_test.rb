require 'test_helper'

class LeaveTypeTest < ActiveSupport::TestCase

  test "fixture data valid" do
    leave_types.each {|record| assert_valid record }
  end

  test "different leave types can be accessed via class methods" do
    assert LeaveType.annual
    assert LeaveType.educational
    assert LeaveType.medical
    assert LeaveType.maternity
    assert LeaveType.compassionate
  end
  
  test "leave types should be scoped to the account" do
    account = accounts(:one)
    assert account.leave_types.annual.account == account
    assert account.leave_types.educational.account == account
    assert account.leave_types.medical.account == account
    assert account.leave_types.maternity.account == account
    assert account.leave_types.compassionate.account == account
  end
  
  test "should get cycle index" do
    leave_type = LeaveType.new(:cycle_start_date => Date.new(2011, 1, 1), :cycle_duration => 1)
    assert_equal 0, leave_type.cycle_index_of(Date.new(2011, 1, 1))
    assert_equal 0, leave_type.cycle_index_of(Date.new(2011, 2, 1))
    assert_equal 0, leave_type.cycle_index_of(Date.new(2011, 12, 31))
    assert_equal 1, leave_type.cycle_index_of(Date.new(2012, 1, 1))
    assert_equal 1, leave_type.cycle_index_of(Date.new(2012, 2, 1))
    assert_equal 1, leave_type.cycle_index_of(Date.new(2012, 12, 31))
    assert_equal 2, leave_type.cycle_index_of(Date.new(2013, 1, 1))
  end

  test "should get cycle index over 20 of years" do
    leave_type = LeaveType.new(:cycle_start_date => Date.new(2011, 1, 1), :cycle_duration => 1)
    20.times do |i|
      assert_equal i, leave_type.cycle_index_of(Date.new(2011 + i, 1, 1))
      assert_equal i, leave_type.cycle_index_of(Date.new(2011 + i, 12, 31))
    end
  end

end
