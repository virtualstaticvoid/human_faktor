require 'date'

module Tenant
  class AccountSetupController < TenantController

    skip_before_filter :check_account_active, :authenticate_employee!, :check_employee

    def initialize
      self.partials_path = 'admin'
      super
    end
    
    def edit
      @account = current_account
      
      # setup already?
      redirect_to dashboard_url and return if @account.active?
      
      registration = @account.registration
      @account_setup = AccountSetup.new().tap do |setup|
        setup.admin_first_name = registration.first_name
        setup.admin_last_name = registration.last_name
        setup.admin_user_name = registration.user_name
        setup.admin_email = registration.email
        setup.fixed_daily_hours = @account.fixed_daily_hours
        setup.leave_cycle_start_date = Date.new(Date.today.year, 1, 1)

        LeaveType.for_each_leave_type_name do |leave_type_name|
          leave_type = @account.send("leave_type_#{leave_type_name}")
          setup.send("#{leave_type_name}_leave_allowance=", leave_type.cycle_days_allowance)
        end

        setup.auth_token = @account.auth_token
        setup.auth_token_confirmation = params[:token] if @account.auth_token == params[:token]
      end
    end
    
    def update
      @account = current_account
      @account_setup = AccountSetup.new(params[:account_setup])
      @account_setup.auth_token = @account.auth_token
      
      respond_to do |format|
        if @account_setup.save(@account) 
          sign_in(:employee, @account.employees.first)
          format.html { redirect_to(dashboard_url, :notice => 'Account successfully setup.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end

  end
end
