module Tenant
  class TenantController < ApplicationController
    layout 'tenant'

    before_filter :check_account_active
    before_filter :authenticate_employee!
    before_filter :check_employee
    before_filter :mark_as_visited

    private

    def check_account_active
      unless current_account.active
        redirect_to account_setup_url and return false
      end
      true
    end
    
    def check_employee
      unless current_employee && current_employee.has_password?
        redirect_to activate_url(:auth_token => params[:auth_token]) and return false
      end
      true
    end

    def mark_as_visited
      session[:visited] = true
    end

  end
end

