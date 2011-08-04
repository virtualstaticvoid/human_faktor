module Tenant
  class DashboardController < TenantController
    layout 'dashboard'
    
    def index
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

    def calendar
    end

    # GET && POST
    def staff_calendar
      redirect_to calendar_url if current_employee.is_employee?

      staff_calendar_params = params[:staff_calendar_enquiry] || {}

      @staff_calendar = StaffCalendarEnquiry.new(current_account, current_employee).tap do |c|
        c.date_from = ApplicationHelper.safe_parse_date(staff_calendar_params[:date_from], Date.today << 6)
        c.date_to = ApplicationHelper.safe_parse_date(staff_calendar_params[:date_to], Date.today >> 6)
        c.valid?
      end

    end
    
    # GET && POST
    def heatmap
      redirect_to dashboard_url unless current_employee.is_admin? || current_employee.is_manager?
      
      heat_map_params = params[:heat_map_enquiry] || {}
      
      @heat_map = HeatMapEnquiry.new(current_account, current_employee).tap do |c| 
        c.enquiry = heat_map_params[:enquiry] if heat_map_params[:enquiry]
        c.date_from = ApplicationHelper.safe_parse_date(heat_map_params[:date_from], Date.today << 6)
        c.date_to = ApplicationHelper.safe_parse_date(heat_map_params[:date_to], Date.today >> 6)
        c.valid?
      end
      
      @leave_types = current_account.leave_types
      
    end
    
    def staff_leave_carry_over
      redirect_to dashboard_url unless current_employee.is_admin? || current_employee.is_manager?
    end
    
    def help
    end

  end
end

