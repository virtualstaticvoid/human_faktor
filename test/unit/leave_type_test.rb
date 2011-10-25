require 'test_helper'

class LeaveTypeTest < ActiveSupport::TestCase

  setup do
    @employee = employees(:employee)
    @employee.start_date = Date.new(2011, 1, 1)
    @employee.take_on_balance_as_at = nil
  end

  test "fixture data valid" do
    for_each_fixture ('leave_types') {|key| assert_valid leave_types(key) }
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
    leave_type = LeaveType.new(
      :cycle_start_date => @employee.start_date, 
      :cycle_duration => 1,
      :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS
    )
    assert_equal 0, leave_type.cycle_index_of(@employee, Date.new(2011, 1, 1))
    assert_equal 0, leave_type.cycle_index_of(@employee, Date.new(2011, 2, 1))
    assert_equal 0, leave_type.cycle_index_of(@employee, Date.new(2011, 12, 31))
    assert_equal 1, leave_type.cycle_index_of(@employee, Date.new(2012, 1, 1))
    assert_equal 1, leave_type.cycle_index_of(@employee, Date.new(2012, 2, 1))
    assert_equal 1, leave_type.cycle_index_of(@employee, Date.new(2012, 12, 31))
    assert_equal 2, leave_type.cycle_index_of(@employee, Date.new(2013, 1, 1))
    assert_equal 2, leave_type.cycle_index_of(@employee, Date.new(2013, 2, 1))
    assert_equal 2, leave_type.cycle_index_of(@employee, Date.new(2013, 12, 31))
    assert_equal 3, leave_type.cycle_index_of(@employee, Date.new(2014, 1, 1))
    assert_equal 3, leave_type.cycle_index_of(@employee, Date.new(2014, 2, 1))
    assert_equal 3, leave_type.cycle_index_of(@employee, Date.new(2014, 12, 31))
  end

  test "should get cycle index over 20 periods (years)" do
    start_date = @employee.start_date
    end_date = start_date + 1.year - 1.day
    leave_type = LeaveType.new(
      :cycle_start_date => start_date,
      :cycle_duration => 1,
      :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS
    )
    (0..19).each do |i|
      assert_equal i, leave_type.cycle_index_of(@employee, start_date)
      assert_equal i, leave_type.cycle_index_of(@employee, end_date)
      start_date += 1.year
      end_date += 1.year
    end
  end
  
  test "should get cycle index over 20 periods (months)" do
    start_date = @employee.start_date
    end_date = start_date + 1.month - 1.day
    leave_type = LeaveType.new(
      :cycle_start_date => start_date,
      :cycle_duration => 1,
      :cycle_duration_unit => LeaveType::DURATION_UNIT_MONTHS
    )
    (0..19).each do |i|
      assert_equal i, leave_type.cycle_index_of(@employee, start_date)
      assert_equal i, leave_type.cycle_index_of(@employee, end_date)
      start_date += 1.month
      end_date += 1.month
    end
  end

  test "should get cycle index over 20 periods (days)" do
    start_date = @employee.start_date
    end_date = start_date + 29.days
    leave_type = LeaveType.new(
      :cycle_start_date => start_date,
      :cycle_duration => 30,
      :cycle_duration_unit => LeaveType::DURATION_UNIT_DAYS
    )
    (0..19).each do |i|
      assert_equal i, leave_type.cycle_index_of(@employee, start_date)
      assert_equal i, leave_type.cycle_index_of(@employee, end_date)
      start_date += 30.days
      end_date += 30.days
    end
  end

  test "should calculate cycle indexes, start and end dates (employee-start-date)" do
    LeaveType.for_each_leave_type do |leave_type_class|
      @employee.start_date = Date.new(2000, 1, 1)
      leave_type = leave_type_class.new(
        :cycle_start_date => @employee.start_date,
        :cycle_duration => 1,
        :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS
      )

      next if leave_type.has_absolute_start_date?

      assert_equal 0, leave_type.cycle_index_of(@employee, Date.new(2000, 1, 1))
      assert_equal Date.new(2000, 1, 1), leave_type.cycle_start_date_for(@employee, 0)
      assert_equal Date.new(2000, 1, 1), leave_type.cycle_start_date_of(@employee, Date.new(2000, 2, 1))
      
      end_date = case leave_type.cycle_duration_unit
                    when LeaveType::DURATION_UNIT_DAYS then leave_type.cycle_start_date + leave_type.cycle_duration
                    when LeaveType::DURATION_UNIT_MONTHS then leave_type.cycle_start_date >> leave_type.cycle_duration
                    when LeaveType::DURATION_UNIT_YEARS then leave_type.cycle_start_date >> (leave_type.cycle_duration * 12)
                  end - 1
      
      assert_equal end_date, leave_type.cycle_end_date_of(@employee, Date.new(2000, 2, 1))
    end
  end

  test "should calculate cycle indexes, start and end dates (absolute-start-date)" do
    LeaveType.for_each_leave_type do |leave_type_class|
      leave_type = leave_type_class.new()

      next unless leave_type.has_absolute_start_date?

      # TODO

    end
  end

  test "should have zero allowance when date before start date of employee" do
    employee = employees(:employee)
    employee.start_date = Date.new(2000, 2, 1)
    employee.take_on_balance_as_at = nil

    LeaveType.for_each_leave_type do |leave_type_class|
      leave_type = leave_type_class.new(
        :cycle_start_date => Date.new(2000, 1, 1),
        :cycle_duration => 1,
        :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS
      )
      
      assert_equal 0, leave_type.allowance_for(employee, Date.new(2000, 1, 1))
      assert_equal 0, leave_type.allowance_for(employee, Date.new(2000, 2, 1))

      assert leave_type.allowance_for(employee, Date.new(2000, 4, 1)) > 0
      assert_equal leave_type.cycle_days_allowance, leave_type.allowance_for(employee, Date.new(2001, 2, 1))
    end
  end

  test "should have zero allowance when date before balance take on date of employee" do
    employee = employees(:employee)
    employee.start_date = Date.new(2000, 1, 1)
    employee.take_on_balance_as_at = Date.new(2000, 2, 1)

    LeaveType.for_each_leave_type do |leave_type_class|
      leave_type = leave_type_class.new(
        :cycle_start_date => Date.new(2000, 1, 1),
        :cycle_duration => 1,
        :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS
      )
      
      assert_equal 0, leave_type.allowance_for(employee, Date.new(2000, 1, 1))
      assert_equal 0, leave_type.allowance_for(employee, Date.new(2000, 2, 1))
      assert leave_type.allowance_for(employee, Date.new(2000, 3, 1)) > 0
    end
  end

end
