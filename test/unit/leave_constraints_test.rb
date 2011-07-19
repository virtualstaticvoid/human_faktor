require 'test_helper'
require 'date'

class LeaveConstraintsTest < ActiveSupport::TestCase

  setup do
    @leave_request = leave_requests(:annual)
  end

  test "should evaluate all constraints" do
    LeaveConstraints::Base.evaluate(@leave_request)
  end
  
  test "evaluate should yield true or false result" do
    constraint_flags = LeaveConstraints::Base.evaluate(@leave_request)
    constraint_flags.each do |key, value| 
      assert_equal false, value.nil?
      assert value.is_a?(true.class) || value.is_a?(false.class)
    end
  end

  test "ExceedsNumberOfDaysNoticeRequired" do
    constraint = LeaveConstraints::ExceedsNumberOfDaysNoticeRequired.new()

    leave_request = @leave_request
    leave_request.leave_type.required_days_notice = 1

    leave_request.date_from = leave_request.created_at.to_date - 1
    leave_request.update_duration
    assert constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date
    leave_request.update_duration
    assert constraint.evaluate(leave_request)

    leave_request.date_from += leave_request.leave_type.required_days_notice.to_i
    leave_request.update_duration
    assert_equal false, constraint.evaluate(leave_request)

  end

  test "ExceedsMinimumNumberOfDaysPerRequest" do
    constraint = LeaveConstraints::ExceedsMinimumNumberOfDaysPerRequest.new()

    leave_request = @leave_request
    leave_request.leave_type.min_days_per_single_request = 2

    leave_request.date_from = Date.new(2011, 6, 13)
    leave_request.date_to = leave_request.date_from
    leave_request.update_duration
    assert constraint.evaluate(leave_request)

    # ensure an integer is added to the date!
    leave_request.date_to = leave_request.date_from + (leave_request.leave_type.min_days_per_single_request + 1).to_i
    leave_request.update_duration
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_to += 1
    leave_request.update_duration
    assert_equal false, constraint.evaluate(leave_request)
    
  end

  test "ExceedsMaximumNumberOfDaysPerRequest" do
    constraint = LeaveConstraints::ExceedsMaximumNumberOfDaysPerRequest.new()

    leave_request = @leave_request
    leave_request.leave_type.max_days_per_single_request = 2

    leave_request.date_from = Date.new(2011, 6, 13)
    leave_request.date_to = Date.new(2011, 6, 17)
    leave_request.update_duration
    assert constraint.evaluate(leave_request)

    leave_request.date_to = Date.new(2011, 6, 13)
    leave_request.update_duration
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_to = Date.new(2011, 6, 14)
    leave_request.update_duration
    assert_equal false, constraint.evaluate(leave_request)
    
  end

  test "ExceedsLeaveCycleAllowance" do
    constraint = LeaveConstraints::ExceedsLeaveCycleAllowance.new()
  
    #
    # TODO: implement test for ExceedsLeaveCycleAllowance
    #
  
    # NOTE: check that the employee take on balance is included
  
    pending
  end

  test "ExceedsNegativeLeaveBalance" do
    constraint = LeaveConstraints::ExceedsNegativeLeaveBalance.new()
  
    #
    # TODO: implement test for ExceedsNegativeLeaveBalance
    #

    # NOTE: check that the employee take on balance is included
  
    pending
  end

  test "IsUnscheduled" do
    constraint = LeaveConstraints::IsUnscheduled.new()

    leave_request = @leave_request
    leave_request.leave_type.unscheduled_leave_allowed = false
    
    leave_request.date_from = leave_request.created_at.to_date - 1
    leave_request.date_to = leave_request.date_from
    assert constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date + 1
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.leave_type.unscheduled_leave_allowed = true

    leave_request.date_from = leave_request.created_at.to_date - 1
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date + 1
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)
    
  end

  test "IsAdjacent" do
    constraint = LeaveConstraints::IsAdjacent.new()

    leave_request = @leave_request

    ##
    # before Saturday or after Sunday
    
    #  before
    leave_request.date_from = Date.new(2011, 6, 17) # Friday
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert constraint.evaluate(leave_request)

    leave_request.date_from = Date.new(2011, 6, 16) # Thursday
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert_equal false, constraint.evaluate(leave_request)

    #  after
    leave_request.date_from = Date.new(2011, 6, 20) # Monday
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert constraint.evaluate(leave_request)

    leave_request.date_from = Date.new(2011, 6, 21) # Tuesday
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert_equal false, constraint.evaluate(leave_request)
    
    ##
    # before or after public holiday
    holiday_date = Date.new(2011, 6, 15)
    leave_request.account.country.calendar_entries.build(:title => 'Banana Day', :entry_date => holiday_date).save!

    #  before    
    leave_request.date_from = holiday_date - 1
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert constraint.evaluate(leave_request)

    leave_request.date_from = holiday_date - 3
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert_equal false, constraint.evaluate(leave_request)

    #  after
    leave_request.date_from = holiday_date + 1
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert constraint.evaluate(leave_request)

    leave_request.date_from = holiday_date + 3
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert_equal false, constraint.evaluate(leave_request)
    
    ##
    # before or after scheduled leave

    approved_leave_request = leave_requests(:annual2)
    approved_leave_request.date_from = Date.new(2011, 6, 29)
    approved_leave_request.date_to = approved_leave_request.date_from
    approved_leave_request.confirm
    approved_leave_request.approve!(employees(:admin), '') # NB: must be approved
    
    #  before
    leave_request.date_from = approved_leave_request.date_from - 1
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert constraint.evaluate(leave_request)

    leave_request.date_from = approved_leave_request.date_from - 3
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert_equal false, constraint.evaluate(leave_request)
    
    #  after
    leave_request.date_from = approved_leave_request.date_from + 1
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert constraint.evaluate(leave_request)

    leave_request.date_from = approved_leave_request.date_from + 3
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert_equal false, constraint.evaluate(leave_request)

    # edge case... on the same date (overlapping constraint handles this)
    leave_request.date_from = approved_leave_request.date_from
    leave_request.date_to = leave_request.date_from
    leave_request.send :write_attribute, :created_at, leave_request.date_from + 1
    assert_equal false, constraint.evaluate(leave_request)

  end

  # NB: internet connection to S3 required 
  test "RequiresDocumentation" do
    constraint = LeaveConstraints::RequiresDocumentation.new()

    leave_request = @leave_request

    # doesn't require documentation
    leave_request.leave_type.requires_documentation = false
    assert_equal false, constraint.evaluate(leave_request)

    # requires documentation
    leave_request.leave_type.requires_documentation = true
    leave_request.leave_type.requires_documentation_after = 1

    leave_request.date_from = Date.new(2011, 6, 13)
    leave_request.date_to = leave_request.date_from
    leave_request.update_duration
    assert constraint.evaluate(leave_request)

    leave_request.leave_type.requires_documentation_after = 2
    
    #   1 day
    leave_request.date_to = leave_request.date_from
    leave_request.update_duration
    assert_equal false, constraint.evaluate(leave_request)

    #   2 days
    leave_request.date_to = leave_request.date_from + 1
    leave_request.update_duration
    assert constraint.evaluate(leave_request)

    #   more than 2 days
    leave_request.date_to = leave_request.date_from + 2 
    leave_request.update_duration
    assert constraint.evaluate(leave_request)

    # attached a file...
    leave_request.document = File.new(File.join(FIXTURES_DIR, 'document.txt'), 'r')
    leave_request.leave_type.requires_documentation_after = 1

    leave_request.date_from = Date.new(2011, 6, 13)
    leave_request.date_to = leave_request.date_from
    leave_request.update_duration
    assert_equal false, constraint.evaluate(leave_request)

  end
  
  test "OverlappingRequest" do
    constraint = LeaveConstraints::OverlappingRequest.new()

    leave_request = @leave_request

    approved_leave_request = leave_requests(:annual2)
    approved_leave_request.date_from = Date.new(2011, 7, 6)
    approved_leave_request.date_to = approved_leave_request.date_from
    approved_leave_request.confirm
    approved_leave_request.approve!(employees(:admin), '') # NB: must be approved

    leave_request.date_from = Date.new(2011, 7, 4)
    leave_request.date_to = Date.new(2011, 7, 8)
    assert constraint.evaluate(leave_request)

    leave_request.date_to = Date.new(2011, 7, 5)
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = Date.new(2011, 7, 7)
    leave_request.date_to = Date.new(2011, 7, 8)
    assert_equal false, constraint.evaluate(leave_request)

  end

  test "ExceedsMaximumFutureDate" do
    constraint = LeaveConstraints::ExceedsMaximumFutureDate.new()

    leave_request = @leave_request
    leave_request.leave_type.max_days_for_future_dated = 2

    leave_request.date_from = leave_request.created_at.to_date
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date + 1
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date + 2
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date + leave_request.leave_type.max_days_for_future_dated + 1
    leave_request.date_to = leave_request.date_from
    assert constraint.evaluate(leave_request)

  end

  test "ExceedsMaximumBackDate" do
    constraint = LeaveConstraints::ExceedsMaximumBackDate.new()

    leave_request = @leave_request
    leave_request.leave_type.max_days_for_back_dated = 2

    leave_request.date_from = leave_request.created_at.to_date
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date - 1
    leave_request.date_to = leave_request.date_from
    assert_equal false, constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date - 3
    leave_request.date_to = leave_request.date_from
    assert constraint.evaluate(leave_request)

    leave_request.date_from = leave_request.created_at.to_date - leave_request.leave_type.max_days_for_back_dated - 1
    leave_request.date_to = leave_request.date_from
    assert constraint.evaluate(leave_request)

  end
  
end

