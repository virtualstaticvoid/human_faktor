module Tenant
  class LeaveTypesController < AdminController

    def edit
      @account = current_account
    end

    def update
      @account = current_account

      respond_to do |format|
        if @account.update_attributes(params[:account])
          format.html { redirect_to(edit_leave_types_path, :notice => 'Leave policies successfully updated.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end

  end
end
