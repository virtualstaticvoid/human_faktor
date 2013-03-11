require 'test_helper'

class LeaveTypeTest < ActiveSupport::TestCase

  setup do
    @account = accounts(:one)
    @employee = employees(:employee)
    @employee.start_date = Date.new(2011, 1, 1)
    @employee.take_on_balance_as_at = nil
  end

  test "fixture data valid" do
    for_each_fixture ('leave_types') {|key| assert_valid leave_types(key) }
  end

  test "provides hex color" do
    for_each_fixture ('leave_types') {|key| assert leave_types(key).hex_color }
  end

  test "provides duration display text" do
    for_each_fixture ('leave_types') {|key| assert leave_types(key).duration_display }
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
    assert_equal account, account.leave_types.annual.account
    assert_equal account, account.leave_types.educational.account
    assert_equal account, account.leave_types.medical.account
    assert_equal account, account.leave_types.maternity.account
    assert_equal account, account.leave_types.compassionate.account
  end
  
  test "should have zero allowance when date before start date of employee" do
    employee = employees(:employee)
    employee.start_date = Date.new(2000, 2, 1)
    employee.take_on_balance_as_at = nil

    LeaveType.for_each_leave_type do |leave_type_class|
      leave_type = leave_type_class.new(
        :account_id => @account.id,
        :cycle_start_date => Date.new(2000, 1, 1),
        :cycle_duration => 1,
        :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS,
        :cycle_days_allowance => 21
      )
      # assert leave_type.valid?

      assert_equal 0, leave_type.allowance_for(employee, Date.new(2000, 1, 1)), "leave_type => #{leave_type}"
    end
  end

  test "should have zero allowance when date before balance take on date of employee" do
    employee = employees(:employee)
    employee.start_date = Date.new(2000, 1, 1)
    employee.take_on_balance_as_at = Date.new(2000, 2, 1)

    LeaveType.for_each_leave_type do |leave_type_class|
      leave_type = leave_type_class.new(
        :account_id => @account.id,
        :cycle_start_date => Date.new(2000, 1, 1),
        :cycle_duration => 1,
        :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS,
        :cycle_days_allowance => 21
      )
      # assert leave_type.valid?
      
      assert_equal 0, leave_type.allowance_for(employee, Date.new(2000, 1, 1)), "leave_type => #{leave_type}"
      assert_equal 0, leave_type.allowance_for(employee, Date.new(2000, 1, 31)), "leave_type => #{leave_type}"
      assert leave_type.allowance_for(employee, Date.new(2000, 3, 1)) > 0, "leave_type => #{leave_type}"
    end
  end

  test "should allocate full allowance for full year" do
    employee = employees(:employee)
    employee.start_date = Date.new(2000, 2, 1)
    employee.take_on_balance_as_at = nil

    LeaveType.for_each_leave_type do |leave_type_class|
      leave_type = leave_type_class.new(
        :account_id => @account.id,
        :cycle_start_date => Date.new(2000, 2, 1),
        :cycle_duration => 1,
        :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS,
        :cycle_days_allowance => 21
      )
      # assert leave_type.valid?

      assert leave_type.allowance_for(employee, Date.new(2000, 4, 1)) > 0, "leave_type => #{leave_type}"
      assert_equal leave_type.cycle_days_allowance,
                   leave_type.allowance_for(employee, (employee.start_date >> 12) - 1).to_i,
                   "leave_type => #{leave_type}, employee.start_date => #{employee.start_date}, to_date => #{(employee.start_date >> 12) - 1}"
    end
  end

end
