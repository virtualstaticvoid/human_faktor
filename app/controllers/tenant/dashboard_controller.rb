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
    
    def problem_staff
      redirect_to dashboard_url if current_employee.is_employee?
    end
    
    def staff_leave_carry_over
      redirect_to dashboard_url if current_employee.is_employee?
    end
    
    def help
    end

  end
end

