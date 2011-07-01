module Tenant
  class AccountSetupController < TenantController

    skip_before_filter :authenticate_employee!

    def initialize
      self.partials_path = 'admin'
      super
    end

    def index
      # TODO: validate account state inactive
      # TODO: validate token
    end

  end
end
