module Tenant
  class EmployeeLeaveRequestsController < DashboardController
    
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

