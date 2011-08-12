module Tenant
  class EmployeeLeaveRequestsController < DashboardController
    
    def index
      status_filter = params[:status] || LeaveRequest::STATUS_PENDING
      from_date = ApplicationHelper.safe_parse_date(params[:from])
      to_date = ApplicationHelper.safe_parse_date(params[:to])

      # status filter
      if status_filter == LeaveRequest::STATUS_PENDING
        @leave_requests = current_employee.leave_requests.pending.page(params[:page])
      else
        @leave_requests = current_employee.leave_requests.where(:status => status_filter).page(params[:page])
      end

      # date filter
      if from_date && to_date
        @leave_requests = @leave_requests
            .where(
              ' (date_from BETWEEN :from_date AND :to_date ) OR ( date_to BETWEEN :from_date AND :to_date ) ',
              { :from_date => from_date, :to_date => to_date } 
            )
      end

      @leave_requests = @leave_requests.order(:date_from)

    end

    def new
      if params[:request].present? && (@leave_request = current_account.leave_requests.find_by_identifier(params[:request]))
        @leave_request = LeaveRequest.new(@leave_request.attributes)
      else
        @leave_request = LeaveRequest.new()
        @leave_request.employee = current_employee
        @leave_request.approver = current_employee.approver
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
      
      # insert correct employee id
      leave_request_params[:employee_id] = current_employee.id
      
      # insert approver if not specified (or not allowed to specify)
      # TODO: ensure that the approver selected is allowed for this employee
      leave_request_params.merge!({
        'approver_id' => current_employee.approver_id
      }) unless current_employee.can_choose_own_approver? && leave_request_params[:approver_id].present?
      
      @leave_request = current_account.leave_requests.build(leave_request_params)

      respond_to do |format|
        if @leave_request.request!
          if @leave_request.has_constraint_violations?
            format.html { redirect_to edit_leave_request_url(@leave_request, :tenant => current_account.subdomain), :notice => 'Warnings issued for leave request. Please review!' }
          else
            format.html { redirect_to(dashboard_url, :notice => 'Leave request successfully created.') }
          end
        else
          load_leave_types
          format.html { render :action => "new" }
        end
      end
    end
    
    private 
    
    def load_leave_types

      # filter by employee capture permissions and the gender of the employee
      @leave_types = current_account.leave_types_for_employee.select {|leave_type| 
        !(leave_type.gender_filter & current_employee.gender_filter).empty?
      }

    end
    
  end
end

