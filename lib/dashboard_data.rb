class DashboardData

  attr_reader :account
  attr_reader :employee

  def initialize(account, employee)
    @account = account
    @employee = employee
  end
  
  def pending_leave_requests
    @pending_leave_requests ||= @employee.leave_requests.pending.limit(10)
  end

end
