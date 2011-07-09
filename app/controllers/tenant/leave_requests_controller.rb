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

      respond_to do |format|
        if @leave_request.reinstate!(current_employee)
          format.html { redirect_to dashboard_url, :notice => 'Leave request successfully reinstated.' }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
  end
end

