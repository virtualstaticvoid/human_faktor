module Tenant
  class EmployeeLeaveRequestsController < DashboardController
    
    def index
      status_filter = params[:status] || LeaveRequest::STATUS_PENDING
      if status_filter == LeaveRequest::STATUS_PENDING
        @leave_requests = current_employee.leave_requests.pending.page(params[:page])
      else
        @leave_requests = current_employee.leave_requests.where(:status => status_filter).page(params[:page])
      end
    end

    def new
      @leave_request = LeaveRequest.new()
      @leave_request.approver = current_employee.approver
      @leave_request.leave_type_id = params[:leave_type] if params[:leave_type]
      @leave_request.date_from = params[:from] || Date.today
      @leave_request.date_to = params[:to] if params[:to]

      respond_to do |format|
        format.html # new.html.erb
      end
    end

    # POST
    def create
      leave_request_params = params[:leave_request]
      
      # insert correct employee id
      leave_request_params[:employee_id] = current_employee.id
      
      # insert approver if not specified (or not allowed to specify)
      leave_request_params.merge!({
        'approver_id' => current_employee.approver_id
      }) unless current_employee.can_choose_own_approver? && leave_request_params[:approver_id].present?
      
      @leave_request = current_account.leave_requests.build(leave_request_params)

      respond_to do |format|
        if @leave_request.request!
          if @leave_request.has_constraint_violations?
            format.html { redirect_to edit_leave_request_url(@leave_request, :tenant => current_account.subdomain), :notice => 'Warnings issued for leave request. Please review!' }
          else
            format.html { redirect_to(dashboard_url, :notice => 'Leave request successfully created.') }
          end
        else
          format.html { render :action => "new" }
        end
      end
    end
    
  end
end

