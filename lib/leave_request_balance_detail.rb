class LeaveRequestBalanceDetail < LeaveBalanceDetail

  attr_reader :projected

  def initialize(leave_request)
    super(leave_request.leave_type, leave_request.employee, leave_request.date_from)
    @projected = @available - leave_request.duration
  end
  
end
