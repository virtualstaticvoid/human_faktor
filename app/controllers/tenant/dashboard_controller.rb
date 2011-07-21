module Tenant
  class DashboardController < TenantController
    layout 'dashboard'
    
    def index
    end

    def profile
    end

    def balance
      @date_as_at = ApplicationHelper.safe_parse_date(params[:as_at], Date.today)
      @account = current_account
      @employee = params[:employee].present? ?
                    current_account.employees.find_by_identifier(params[:employee]) :
                    current_employee
    
      # get leave types, filtered by the gender of the employee
      @leave_types = current_account.leave_types.select {|leave_type| 
        !(leave_type.gender_filter & @employee.gender_filter).empty?
      }
    
      # permission check
      if @employee != current_employee && !current_employee.is_manager_of?(@employee) 
        redirect_to dashboard_url and return false
      end
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

