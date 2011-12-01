class DashboardData

  attr_reader :account
  attr_reader :employee

  def initialize(account, employee)
    @account = account
    @employee = employee
  end
  
  def pending_leave_requests
    @pending_leave_requests ||= @employee.leave_requests
      .pending
      .limit(10)
  end
  
  def pending_staff_leave_requests
    @pending_staff_leave_requests ||= (
      if @employee.is_admin?
        @account.leave_requests
      elsif @employee.is_manager?
        @account.leave_requests.where(:approver_id => @employee.staff)
      elsif @employee.is_approver?
        @account.leave_requests.where(:approver_id => @employee.id)
      else
        @employee.leave_requests
      end
    ).pending
     .limit(10)
  end
  
  def recent_leave_requests
    @recent_leave_requests ||= @employee.leave_requests
      .approved
      .order('created_at DESC')
      .limit(10)
  end
  
  def leave_requests_requiring_documentation
    @leave_requests_requiring_documentation = @employee.leave_requests
      .approved
      .where(:requires_documentation.as_constraint_override => true)
      .limit(10)
  end

  def staff_leave_requests_requiring_documentation
    @staff_leave_requests_requiring_documentation ||= (
      if @employee.is_admin?
        @account.leave_requests
      elsif @employee.is_manager?
        @account.leave_requests.where(:approver_id => @employee.staff)
      elsif @employee.is_approver?
        @account.leave_requests.where(:approver_id => @employee.id)
      else
        @employee.leave_requests
      end
    ).approved
     .where(:requires_documentation.as_constraint_override => true)
     .limit(10)
  end
  
  def annual_leave_type
    @account.leave_types.annual
  end
  
  def unscheduled_leave_heatmap
    @unscheduled_leave_heatmap ||= HeatMapEnquiry.new(@account, @employee).tap do |c|
      c.enquiry = 'HeatMapEnquiry::UnscheduledLeave'
      c.date_from = @account.leave_type_annual.cycle_start_date_for(Date.today)
      c.date_to = @account.leave_type_annual.cycle_end_date_for(Date.today)
    end
  end
  
end
