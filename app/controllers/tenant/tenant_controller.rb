module Tenant
  class TenantController < ApplicationController
    layout 'tenant'

    before_filter :ensure_account
    before_filter :authenticate_employee!

  end
end

