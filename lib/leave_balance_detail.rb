class LeaveBalanceDetail

  attr_reader :leave_type

  attr_reader :take_on
  attr_reader :carried_forward
  attr_reader :allowance
  attr_reader :leave_taken
  attr_reader :available

  attr_reader :outstanding
  attr_reader :projected

  attr_reader :unpaid_leave_taken
  attr_reader :cycle_start_date
  attr_reader :cycle_end_date

  def initialize(leave_type, employee, date_as_at)
    @leave_type = leave_type

    @take_on = leave_type.take_on_balance_for(employee, date_as_at)
    @carried_forward = leave_type.leave_carried_forward_for(employee, date_as_at)
    @allowance = leave_type.allowance_for(employee, date_as_at)
    @leave_taken = leave_type.leave_taken_for(employee, date_as_at)
    @available = @take_on + @carried_forward + @allowance - @leave_taken

    # future requests
    @outstanding = leave_type.leave_outstanding_for(employee, date_as_at)
    @projected = @available - @outstanding

    # extras
    @unpaid_leave_taken = leave_type.leave_taken_for(employee, date_as_at, true)
    @cycle_start_date = leave_type.cycle_start_date_for(date_as_at, employee)
    @cycle_end_date = leave_type.cycle_end_date_for(date_as_at, employee)
  end
  
end
