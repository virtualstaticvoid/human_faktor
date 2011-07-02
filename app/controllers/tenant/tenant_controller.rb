module Tenant
  class TenantController < ApplicationController
    layout 'tenant'

    before_filter :check_account_active
    before_filter :authenticate_employee!

    private

    def check_account_active
      unless current_account.active
        redirect_to account_setup_url and return false
      end
      true
    end

  end
end

