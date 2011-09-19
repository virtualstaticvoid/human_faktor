class LeaveRequestFilter < DateFilter

  attr_accessor :requires_documentation_only
  
  def initialize()
    @status = LeaveRequest::STATUS_PENDING
  end
  
  def status
    @status
  end
  def status=(value)
    @status = value.to_i
  end
  
  def leave_request_status
    case @status
      when LeaveRequest::FILTER_STATUS_APPROVED # used?
        LeaveRequest::APPROVED_STATUSES
      when LeaveRequest::FILTER_STATUS_ACTIVE
        LeaveRequest::ACTIVE_STATUSES
      else 
        @status
    end
  end
  
  def status?(status)
    @status == status
  end

end
