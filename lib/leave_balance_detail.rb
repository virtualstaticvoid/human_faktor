class LeaveBalanceDetail

  attr_reader :take_on
  attr_reader :allowance
  attr_reader :leave_taken
  attr_reader :outstanding
  attr_reader :available
  attr_reader :projected

  def initialize(leave_request)
    leave_type = leave_request.leave_type
    employee = leave_request.employee
    date_from = leave_request.date_from

    @take_on = leave_type.leave_take_on_for(employee, date_from)
    @allowance = leave_type.allowance_for(employee, date_from)

    @leave_taken = leave_type.leave_taken_for(employee, date_from)
    @outstanding = leave_type.leave_outstanding_for(employee, date_from) # NB: excludes this request

    @available = @take_on + @allowance - @leave_taken
    @projected = @available - leave_request.duration
  end
  
end
