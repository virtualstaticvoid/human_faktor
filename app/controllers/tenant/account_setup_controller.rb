module Tenant
  class AccountSetupController < TenantController

    skip_before_filter :check_account_active, :authenticate_employee!

    def initialize
      self.partials_path = 'admin'
      super
    end
    
    def edit
      @account = current_account
      @account.auth_token_confirmation = params[:token]
    end
    
    def update
      @account = current_account

      respond_to do |format|
        if false # TODO 
          format.html { redirect_to(dashboard_url, :notice => 'Account successfully setup.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end

  end
end
