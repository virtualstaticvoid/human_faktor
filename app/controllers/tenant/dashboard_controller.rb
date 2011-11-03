module Tenant
  class DashboardController < TenantController
    layout 'dashboard'
    
    before_filter :handle_demo_request_trackback

    def index
      # create a holder for all the data instead of separate variables here
      @dashboard = DashboardData.new(current_account, current_employee)
    end
    
    def welcome
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

      @leave_types = current_account.leave_types

      filter_params = params[:staff_balance_enquiry] || {}
      @staff_balance = StaffBalanceEnquiry.new(current_account, current_employee).tap do |c|
        c.date_as_at = ApplicationHelper.safe_parse_date(filter_params[:date_as_at], Date.today)
        c.leave_type_id = filter_params[:leave_type_id] if filter_params[:leave_type_id]
        c.filter_by = @filter_by = filter_params[:filter_by] || 'none'
        c.location_id = filter_params[:location_id] || current_employee.location_id
        c.department_id = filter_params[:department_id] || current_employee.department_id
        c.employee_id = filter_params[:employee_id] || current_employee.id
        
        c.valid?
      end

      @employees = Kaminari.paginate_array(@staff_balance.employees).page(params[:page])
      
    end

    def calendar
    end

    # GET & POST
    def staff_calendar
      redirect_to calendar_url if current_employee.is_employee?

      filter_params = params[:staff_calendar_enquiry] || {}
      @staff_calendar = StaffCalendarEnquiry.new(current_account, current_employee).tap do |c|
        c.date_from = ApplicationHelper.safe_parse_date(filter_params[:date_from], Date.today << 3)
        c.date_to = ApplicationHelper.safe_parse_date(filter_params[:date_to], Date.today >> 6)
        c.filter_by = @filter_by = filter_params[:filter_by] || 'none'
        c.location_id = filter_params[:location_id] || current_employee.location_id
        c.department_id = filter_params[:department_id] || current_employee.department_id
        c.employee_id = filter_params[:employee_id] || current_employee.id
        
        c.valid?
      end

    end
    
    # GET & POST
    def staff_leave_summary
      redirect_to dashboard_url if current_employee.is_employee?

      @leave_types = current_account.leave_types

      filter_params = params[:staff_leave_summary_enquiry] || {}
      @filter = StaffLeaveSummaryEnquiry.new(current_account, current_employee).tap do |c|
        c.date_from = ApplicationHelper.safe_parse_date(filter_params[:date_from], Date.today << 3)
        c.date_to = ApplicationHelper.safe_parse_date(filter_params[:date_to], Date.today >> 6)
        c.filter_by = @filter_by = filter_params[:filter_by] || 'none'
        c.location_id = filter_params[:location_id] || current_employee.location_id
        c.department_id = filter_params[:department_id] || current_employee.department_id
        c.employee_id = filter_params[:employee_id] || current_employee.id
        
        c.valid?
      end

      @employees = Kaminari.paginate_array(@filter.employees).page(params[:page])

    end

    # GET & POST
    def heatmap
      redirect_to dashboard_url unless current_employee.is_admin? || current_employee.is_manager?
      
      filter_params = params[:heat_map_enquiry] || {}
      @heat_map = HeatMapEnquiry.new(current_account, current_employee).tap do |c| 
        c.enquiry = filter_params[:enquiry] if filter_params[:enquiry]
        
        c.date_from = ApplicationHelper.safe_parse_date(filter_params[:date_from], Date.today << 9)
        c.date_to = ApplicationHelper.safe_parse_date(filter_params[:date_to], Date.today >> 3)
        c.filter_by = @filter_by = filter_params[:filter_by] || 'none'
        c.location_id = filter_params[:location_id] || current_employee.location_id
        c.department_id = filter_params[:department_id] || current_employee.department_id
        c.employee_id = filter_params[:employee_id] || current_employee.id
        
        c.valid?
      end
      
    end
    
    def help
    end

  private

    def handle_demo_request_trackback
      unless params[:r].nil?
        demo_request = DemoRequest.find(params[:r])
        demo_request.update_attributes!(:trackback => true) if demo_request
      end
    rescue
      # ignore any errors!
      true
    end

  end
end
