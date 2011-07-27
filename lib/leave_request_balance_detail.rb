class LeaveRequestBalanceDetail < LeaveBalanceDetail

  def initialize(leave_request)
    super(leave_request.leave_type, leave_request.employee, leave_request.date_from)
  end
  
end
