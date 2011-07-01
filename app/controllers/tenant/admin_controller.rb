module Tenant
  class AdminController < TenantController

    # must be an administrator
    before_filter :ensure_admin
    
    def initialize
      self.partials_path = 'admin'
      super
    end

  end
end
