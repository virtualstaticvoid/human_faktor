class LeaveBalanceDetail

  attr_reader :take_on
  attr_reader :allowance
  attr_reader :leave_taken
  attr_reader :unpaid_leave_taken
  attr_reader :outstanding
  attr_reader :available
  attr_reader :projected
  attr_reader :cycle_start_date
  attr_reader :cycle_end_date

  def initialize(leave_type, employee, date_as_at)
    @take_on = leave_type.leave_take_on_for(employee, date_as_at)
    @allowance = leave_type.allowance_for(employee, date_as_at)
    @leave_taken = leave_type.leave_taken_for(employee, date_as_at)
    @unpaid_leave_taken = leave_type.leave_taken_for(employee, date_as_at, true)
    @outstanding = leave_type.leave_outstanding_for(employee, date_as_at)
    @available = @take_on + @allowance - @leave_taken
    @projected = @available - @outstanding
    @cycle_start_date = leave_type.cycle_start_date_of(employee, date_as_at)
    @cycle_end_date = leave_type.cycle_end_date_of(employee, date_as_at)
  end
  
end
