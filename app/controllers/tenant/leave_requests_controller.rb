module Tenant
  class LeaveRequestsController < DashboardController

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
        if @leave_request.confirm!(current_employee)
          format.html { redirect_to dashboard_url, :notice => "Leave request successfully #{@leave_request.captured? ? 'captured' : 'created'}." }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    # PUT
    def approve
      leave_request_params = params[:leave_request]
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      
      unless @leave_request.can_authorise?(current_employee)
        redirect_to(dashboard_url, :notice => 'You are not authorized to perform this action.') and return
      end
      
      @leave_request.unpaid = leave_request_params[:unpaid]

      respond_to do |format|
        if @leave_request.approve!(current_employee, leave_request_params[:approver_comment])
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully approved.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    # PUT
    def decline
      leave_request_params = params[:leave_request]
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      
      unless @leave_request.can_authorise?(current_employee)
        redirect_to(dashboard_url, :notice => 'You are not authorized to perform this action.') and return
      end
      
      respond_to do |format|
        if @leave_request.decline!(current_employee, leave_request_params[:approver_comment])
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully declined.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    # PUT
    def cancel
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      
      unless @leave_request.can_cancel?(current_employee)
        redirect_to(dashboard_url, :notice => 'You are not authorized to perform this action.') and return
      end
      
      respond_to do |format|
        if @leave_request.cancel!(current_employee)
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully cancelled.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    # PUT
    def reinstate
      @leave_request = current_account.leave_requests.find_by_identifier(params[:id])
      
      unless @leave_request.can_authorise?(current_employee)
        redirect_to(dashboard_url, :notice => 'You are not authorized to perform this action.') and return
      end
      
      respond_to do |format|
        if @leave_request.reinstate!(current_employee)
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully reinstated.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    #
    # NOTE: employee parameter uses the employee id and not the identifier!
    #
    def balance
      @employee = current_account.employees.find(params[:employee]) if params[:employee].present?
    
      # permission check
      if !@employee.nil? && @employee != current_employee && !current_employee.is_manager_of?(@employee)
        redirect_to dashboard_url and return false
      end
      
      @leave_type = current_account.leave_types.find(params[:leave_type]) if params[:leave_type].present?
      @date_from = ApplicationHelper.safe_parse_date(params[:date_from])
      @half_day_from = params[:half_day_from] == '1'
      @date_to = ApplicationHelper.safe_parse_date(params[:date_to])
      @half_day_to = params[:half_day_to] == '1'
      @unpaid = params[:unpaid] == '1'

      respond_to do |format|
        format.js
      end
    end
    
  end
end

