module Tenant
  class LeaveRequestsController < DashboardController
    
    # TODO: filter available leave types based on role of employee

    def employee_index
      status_filter = params[:status] || LeaveRequest::STATUS_PENDING
      if status_filter == LeaveRequest::STATUS_PENDING
        @leave_requests = current_employee.leave_requests.pending.page(params[:page])
      else
        @leave_requests = current_employee.leave_requests.where(:status => status_filter).page(params[:page])
      end
    end

    def staff_index
      status_filter = params[:status] || LeaveRequest::STATUS_PENDING

      if current_employee.is_admin?
        @leave_requests = current_account.leave_requests
      elsif current_employee.is_manager?
        @leave_requests = current_account.leave_requests.where(:approver_id => current_employee.manager_for)
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
      @leave_request.employee = current_employee
      @leave_request.approver = current_employee.approver
      
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
      
      # insert correct employee id
      leave_request_params[:employee_id] = current_employee.id
      
      # insert approver if not specified (or not allowed to specify)
      leave_request_params.merge!({
        'approver_id' => current_employee.approver_id
      }) unless !current_employee.can_choose_own_approver? || leave_request_params[:approver_id]
      
      @leave_request = current_account.leave_requests.build(leave_request_params)

      respond_to do |format|
        if @leave_request.save
          if @leave_request.has_constraint_violations?
            format.html { redirect_to edit_leave_request_url(:tenant => current_account.subdomain, :id => @leave_request.to_param), :notice => 'Warnings issued for Leave request. Please review!' }
          else
            format.html { redirect_to(dashboard_url, :notice => 'Leave request successfully created.') }
          end
        else
          format.html { render :action => "new" }
        end
      end
    end
    
    def edit
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])

      respond_to do |format|
        format.html # edit.html.erb
      end
    end
    
    # PUT
    def confirm
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      respond_to do |format|
        if @leave_request.confirm!
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully created.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    # PUT
    def approve
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      respond_to do |format|
        if @leave_request.approve!
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully approved.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    # PUT
    def decline
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      respond_to do |format|
        if @leave_request.decline!
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully declined.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    # PUT
    def cancel
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      respond_to do |format|
        if @leave_request.cancel!
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully cancelled.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
  end
end

