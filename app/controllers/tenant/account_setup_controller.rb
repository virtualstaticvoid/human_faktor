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
      @administrator = Employee.new(
        :role => :admin, 
        :first_name => @account.registration.first_name,
        :last_name => @account.registration.last_name,
        :user_name => @account.registration.user_name,
        :email => @account.registration.email
      )
    end
    
    def update
      @account = current_account
      
      @administrator = Employee.new(
        params[:account][:employee].merge({
          'account_id' => @account.id,
          'role' => 'admin'
        }))
      #@administrator.approver = @administrator
      @administrator.valid?

      params[:account].delete(:employee)

      @account.update_attributes(params[:account])

      @account.valid?
      @account.errors[:auth_token_confirmation] << "is invalid." unless @account.auth_token == params[:account][:auth_token_confirmation]

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
