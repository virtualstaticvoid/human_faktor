module Tenant
  class StaffLeaveRequestsController < TenantController
    layout 'dashboard'

    def index

      filter_params = params[:leave_request_filter] || {}
      @filter = LeaveRequestFilter.new(current_account, current_employee).tap do |c|
        c.status = filter_params[:status] || LeaveRequest::STATUS_PENDING
        c.date_from = ApplicationHelper.safe_parse_date(filter_params[:date_from])
        c.date_to = ApplicationHelper.safe_parse_date(filter_params[:date_to])
        c.filter_by = @filter_by = filter_params[:filter_by] || 'none'
        c.location_id = filter_params[:location_id] || current_employee.location_id
        c.department_id = filter_params[:department_id] || current_employee.department_id
        c.employee_id = filter_params[:employee_id] || current_employee.id
        c.requires_documentation_only = filter_params[:requires_documentation_only] == '1'

        c.valid?
      end

      # user role filter
      if current_employee.is_admin?
        @leave_requests = current_account.leave_requests
      elsif current_employee.is_manager?
        @leave_requests = current_account.leave_requests.where(:approver_id => current_employee.staff)
      elsif current_employee.is_approver?
        @leave_requests = current_account.leave_requests.where(:approver_id => current_employee.id)
      else
        @leave_requests = current_employee.leave_requests
      end

      # apply location, department or employee filter
      case @filter_by
        when 'location' then
          @leave_requests = @leave_requests.joins(:employee)
                              .where(:employees => { :location_id => @filter.location_id })
        when 'department' then
          @leave_requests = @leave_requests.joins(:employee)
                              .where(:employees => { :department_id => @filter.department_id })
        when 'employee' then
          @leave_requests = @leave_requests.where(:employee_id => @filter.employee_id)
      end
      
      # status filter
      if @filter.status == LeaveRequest::STATUS_PENDING
        @leave_requests = @leave_requests.pending
      else
        @leave_requests = @leave_requests.where(:status => @filter.leave_request_status)
      end
      
      # date filter
      if @filter.valid? && @filter.date_from && @filter.date_to
        @leave_requests = @leave_requests
            .where(
              ' (date_from BETWEEN :from_date AND :to_date ) OR ( date_to BETWEEN :from_date AND :to_date ) ',
              { :from_date => @filter.date_from, :to_date => @filter.date_to } 
            )
      elsif @filter.date_from
        @leave_requests = @leave_requests
            .where(
              ' (date_from >= :from_date ) ',
              { :from_date => @filter.date_from } 
            )
      elsif @filter.date_to
        @leave_requests = @leave_requests
            .where(
              ' (date_to <= :to_date ) ',
              { :to_date => @filter.date_to } 
            )
      end
      
      # requires documentation only?
      if @filter.requires_documentation_only == true
        @leave_requests = @leave_requests
            .where(:requires_documentation.as_constraint_override => true)
      end
      
      @leave_requests = @leave_requests.order('created_at DESC').page(params[:page])
      
    end

    def new
      if params[:request].present? && (@leave_request = current_account.leave_requests.find_by_identifier(params[:request]))
        @leave_request = LeaveRequest.new(@leave_request.attributes)
      else
        @leave_request = LeaveRequest.new()
        @leave_request.employee_id = params[:employee] if params[:employee]
        @leave_request.approver = current_employee
        @leave_request.leave_type_id = params[:leave_type].present? ? params[:leave_type] : current_account.leave_type_annual.id
        @leave_request.date_from = params[:from] if params[:from]
        @leave_request.half_day_from = params[:half_day_from] == "1"
        @leave_request.date_to = params[:to] if params[:to]
        @leave_request.half_day_to = params[:half_day_to] == "1"
        @leave_request.unpaid = params[:unpaid] == "1"
        @leave_request.comment = params[:comment] if params[:comment]
      end

      load_leave_types

      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    # POST
    def create
      leave_request_params = params[:leave_request]
    
      @leave_request = current_account.leave_requests.build(leave_request_params)

      respond_to do |format|
        if @leave_request.capture!(current_employee)
          if @leave_request.has_constraint_violations?
            format.html { redirect_to leave_request_url(@leave_request, :tenant => current_account.subdomain), :notice => 'Warnings issued for leave request. Please review!' }
          else
            format.html { redirect_to(dashboard_url, :notice => 'Leave request successfully captured.') }
          end
        else
          load_leave_types
          format.html { render :action => "new" }
        end
      end
    end
    
    private
    
    def load_leave_types
      # apply filter for approver, manager and admin capture permissions
      if current_employee.is_admin?
        @leave_types = current_account.leave_types_for_admin
      elsif current_employee.is_manager? || current_employee.is_approver?
        @leave_types = current_account.leave_types_for_approver
      else
        @leave_types = current_account.leave_types_for_employee
      end
    end

  end
end

