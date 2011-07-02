require 'date'

module Tenant
  class AccountSetupController < TenantController

    skip_before_filter :check_account_active, :authenticate_employee!

    def initialize
      self.partials_path = 'admin'
      super
    end
    
    def edit
      @account = current_account
      registration = @account.registration
      @account_setup = AccountSetup.new().tap do |setup|
        setup.admin_first_name = registration.first_name
        setup.admin_last_name = registration.last_name
        setup.admin_user_name = registration.user_name
        setup.admin_email = registration.email
        setup.fixed_daily_hours = @account.fixed_daily_hours
        setup.leave_cycle_start_date = Date.new(Date.today.year, 1, 1)
        setup.annual_leave_allowance = @account.leave_type_annual.cycle_days_allowance
        setup.educational_leave_allowance = @account.leave_type_educational.cycle_days_allowance  
        setup.medical_leave_allowance = @account.leave_type_medical.cycle_days_allowance
        setup.maternity_leave_allowance = @account.leave_type_maternity.cycle_days_allowance
        setup.compassionate_leave_allowance = @account.leave_type_compassionate.cycle_days_allowance
        setup.auth_token_confirmation = params[:token]
      end
    end
    
    def update
      @account_setup = AccountSetup.new(params[:account_setup])
  
      respond_to do |format|
        if @account_setup.save(current_account) 
          format.html { redirect_to(dashboard_url, :notice => 'Account successfully setup.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end

  end
end
