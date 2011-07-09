module Tenant
  class StaffLeaveRequestsController < DashboardController
    
    def index
      status_filter = params[:status] || LeaveRequest::STATUS_PENDING

      if current_employee.is_admin?
        @leave_requests = current_account.leave_requests
      elsif current_employee.is_manager?
        @leave_requests = current_account.leave_requests.where(:approver_id => current_employee.staff)
      elsif current_employee.is_approver?
        @leave_requests = current_account.leave_requests.where(:approver_id => current_employee.id)
      else
        @leave_requests = current_employee.leave_requests
      end
      
      # page filter
      if status_filter == LeaveRequest::STATUS_PENDING
        @leave_requests = @leave_requests.pending.page(params[:page])
      else
        @leave_requests = @leave_requests.where(:status => status_filter).page(params[:page])
      end
    end

    def new
      @leave_request = LeaveRequest.new()
      @leave_request.approver = current_employee
      @leave_request.leave_type_id = params[:leave_type] if params[:leave_type]
      @leave_request.date_from = params[:from] if params[:from]
      @leave_request.date_to = params[:to] if params[:to]

      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    # POST
    def create
      leave_request_params = params[:leave_request]
    
      @leave_request = current_account.leave_requests.build(leave_request_params)

      respond_to do |format|
        if @leave_request.capture!(current_employee)
          if @leave_request.has_constraint_violations?
            format.html { redirect_to edit_leave_request_url(:tenant => current_account.subdomain, :id => @leave_request.to_param), :notice => 'Warnings issued for leave request. Please review!' }
          else
            format.html { redirect_to(dashboard_url, :notice => 'Leave request successfully captured.') }
          end
        else
          format.html { render :action => "new" }
        end
      end
    end

  end
end

