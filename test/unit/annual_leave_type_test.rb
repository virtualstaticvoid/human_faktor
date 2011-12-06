require 'test_helper'

class AnnualLeaveTypeTest < ActiveSupport::TestCase

  setup do

    @start_date = Date.new(2011, 1, 1)
    @end_date = Date.new(2011, 12, 31)

    @leave_type = LeaveType::Annual.new()
    @leave_type.cycle_start_date = @start_date
    @leave_type.cycle_duration_unit = LeaveType::DURATION_UNIT_YEARS
    @leave_type.cycle_duration = 1 # year
    @leave_type.cycle_days_allowance = 20
    @leave_type.cycle_days_carry_over = 5

    @existing_employee = Employee.new()
    @existing_employee.start_date = Date.new(2005, 1, 1)
    @existing_employee.take_on_balance_as_at = Date.new(2011, 1, 1)
    @existing_employee.set_take_on_balance_for(@leave_type, 30)

    @new_employee = Employee.new()
    @new_employee.start_date = Date.new(2010, 6, 1)

  end

  # configuration

  test "configuration should have absolute start and end dates for leave cycle" do
    assert @leave_type.has_absolute_start_date?
  end

  test "configuration should carry over leave balances" do
    assert @leave_type.can_carry_over?
  end

  test "configuration should allow take on balances" do
    assert @leave_type.can_take_on?
  end

  test "configuration should not filter on gender" do
    assert_equal 2, @leave_type.gender_filter.length  
  end

  # start date

  test "start dates w/o employee should accept start date" do
    assert_equal @start_date, @leave_type.cycle_start_date_for(Date.new(2011, 1, 1))
  end

  test "start dates w/o employee should accept any date in between" do
    assert_equal @start_date, @leave_type.cycle_start_date_for(Date.new(2011, 6, 30))
  end

  test "start dates w/o employee should accept end date" do
    assert_equal @start_date, @leave_type.cycle_start_date_for(Date.new(2011, 12, 31))
  end

  test "start dates w/o employee should yield previous start date" do
    assert_equal Date.new(2010, 1, 1), @leave_type.cycle_start_date_for(Date.new(2010, 1, 1))
  end

  test "start dates w/o employee should yield next start date" do
    assert_equal Date.new(2012, 1, 1), @leave_type.cycle_start_date_for(Date.new(2012, 1, 1))
  end

  # end date

  test "end dates w/o employee should accept start date" do
    assert_equal @end_date, @leave_type.cycle_end_date_for(Date.new(2011, 1, 1))
  end

  test "end dates w/o employee should accept any date in between" do
    assert_equal @end_date, @leave_type.cycle_end_date_for(Date.new(2011, 6, 30))
  end

  test "end dates w/o employee should accept end date" do
    assert_equal @end_date, @leave_type.cycle_end_date_for(Date.new(2011, 12, 31))
  end

  test "end dates w/o employee should yield previous end date" do
    assert_equal Date.new(2010, 12, 31), @leave_type.cycle_end_date_for(Date.new(2010, 1, 1))
  end

  test "end dates w/o employee should yield next end date" do
    assert_equal Date.new(2012, 12, 31), @leave_type.cycle_end_date_for(Date.new(2012, 1, 1))
  end

  # take_on_balance_for

  test "take_on_balance_for nil employee yields nil" do
    assert_equal nil, @leave_type.take_on_balance_for(nil, Date.new(2011, 1, 1))
  end

  test "take_on_balance_for nil as at date yields nil" do
    assert_equal nil, @leave_type.take_on_balance_for(@new_employee, nil)
  end

  test "take_on_balance_for new employee yields zero" do
    assert_equal 0, @leave_type.take_on_balance_for(@new_employee, Date.new(2011, 1, 1))
  end

  test "take_on_balance_for existing employee within relevant cycle yields take on balance" do
    assert_equal 30, @leave_type.take_on_balance_for(@existing_employee, Date.new(2011, 1, 1))
  end

  test "take_on_balance_for existing employee before take on date yields zero" do
    assert_equal 0, @leave_type.take_on_balance_for(@existing_employee, Date.new(2010, 12, 31))
  end

  test "take_on_balance_for existing employee after relevant cycle date yields zero" do
    assert_equal 0, @leave_type.take_on_balance_for(@existing_employee, Date.new(2012, 1, 1))
  end

  # leave_carried_forward_for
  # allowance_for
  
  # leave_taken_for
  # leave_outstanding_for

end