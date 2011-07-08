class LeaveRequestObserver < ActiveRecord::Observer

  def after_update(leave_request)
  
    mail = if leave_request.status_pending?
             Tenant::LeaveRequestsMailer.pending(leave_request)
           elsif leave_request.status_approved?
             Tenant::LeaveRequestsMailer.approved(leave_request)
           elsif leave_request.status_declined?
             Tenant::LeaveRequestsMailer.declined(leave_request)
           elsif leave_request.status_cancelled?
             Tenant::LeaveRequestsMailer.cancelled(leave_request)
           end

    mail.deliver if mail        

  end

end
