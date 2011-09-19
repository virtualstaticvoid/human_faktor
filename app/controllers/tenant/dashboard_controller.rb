module Tenant
  class DashboardController < TenantController
    layout 'dashboard'
    
    def index
      # create a holder for all the data instead of separate variables here
      @dashboard = DashboardData.new(current_account, current_employee)
    end

    def balance
      @employee = params[:employee].present? ?
                    current_account.employees.find_by_identifier(params[:employee]) :
                    current_employee

      # permission check
      if @employee != current_employee && !current_employee.is_manager_of?(@employee) 
        redirect_to dashboard_url and return false
      end

      @date_as_at = ApplicationHelper.safe_parse_date(params[:as_at], Date.today)
      @account = current_account
    
      # get leave types, filtered by the gender of the employee
      @leave_types = current_account.leave_types.select {|leave_type| 
        !(leave_type.gender_filter & @employee.gender_filter).empty?
      }
      
    end

    # GET & POST
    def staff_balance
      redirect_to balance_url if current_employee.is_employee?

      staff_balance_params = params[:staff_balance_enquiry] || {}
      @leave_types = current_account.leave_types
      @filter_by = staff_balance_params[:filter_by] || 'none'

      @staff_balance = StaffBalanceEnquiry.new(current_account, current_employee).tap do |c|
        c.date_as_at = ApplicationHelper.safe_parse_date(staff_balance_params[:date_as_at], Date.today)
        c.leave_type_id = staff_balance_params[:leave_type_id] if staff_balance_params[:leave_type_id]
        c.filter_by = @filter_by
        c.location_id = staff_balance_params[:location_id]
        c.department_id = staff_balance_params[:department_id]
        c.employee_id = staff_balance_params[:employee_id]
        
        c.valid?
      end
      
    end

    def calendar
    end

    # GET & POST
    def staff_calendar
      redirect_to calendar_url if current_employee.is_employee?

      staff_calendar_params = params[:staff_calendar_enquiry] || {}
      @filter_by = staff_calendar_params[:filter_by] || 'none'

      @staff_calendar = StaffCalendarEnquiry.new(current_account, current_employee).tap do |c|
        c.date_from = ApplicationHelper.safe_parse_date(staff_calendar_params[:date_from], Date.today << 3)
        c.date_to = ApplicationHelper.safe_parse_date(staff_calendar_params[:date_to], Date.today >> 6)
        c.filter_by = @filter_by
        c.location_id = staff_calendar_params[:location_id]
        c.department_id = staff_calendar_params[:department_id]
        c.employee_id = staff_calendar_params[:employee_id]
        
        c.valid?
      end

    end
    
    # GET & POST
    def heatmap
      redirect_to dashboard_url unless current_employee.is_admin? || current_employee.is_manager?
      
      heat_map_params = params[:heat_map_enquiry] || {}
      @filter_by = heat_map_params[:filter_by] || 'none'
      
      @heat_map = HeatMapEnquiry.new(current_account, current_employee).tap do |c| 
        c.enquiry = heat_map_params[:enquiry] if heat_map_params[:enquiry]
        
        c.date_from = ApplicationHelper.safe_parse_date(heat_map_params[:date_from], Date.today << 9)
        c.date_to = ApplicationHelper.safe_parse_date(heat_map_params[:date_to], Date.today >> 3)
        c.filter_by = @filter_by
        c.location_id = heat_map_params[:location_id]
        c.department_id = heat_map_params[:department_id]
        c.employee_id = heat_map_params[:employee_id]
        
        c.valid?
      end
      
    end
    
    def help
    end

  end
end

