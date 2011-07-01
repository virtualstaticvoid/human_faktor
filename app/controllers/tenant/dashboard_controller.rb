module Tenant
  class DashboardController < TenantController
    layout 'dashboard'
    
    def index
    end

    def profile
    end

    def balance
    end

    def calendar
    end

    def staff_calendar
      redirect_to calendar_url if current_employee.is_employee?
    end
    
  end
end

