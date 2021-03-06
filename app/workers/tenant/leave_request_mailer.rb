module Tenant
  class LeaveRequestMailer < Struct.new(:leave_request_id)
    
    def perform()
    
      leave_request = LeaveRequest.find(leave_request_id)
      
      mail = if leave_request.status_pending?
               Tenant::LeaveRequestsMailer.pending(leave_request)
             elsif leave_request.status_approved?
               Tenant::LeaveRequestsMailer.approved(leave_request)
             elsif leave_request.status_declined?
               Tenant::LeaveRequestsMailer.declined(leave_request)
             elsif leave_request.status_cancelled?
               Tenant::LeaveRequestsMailer.cancelled(leave_request)
             elsif leave_request.status_reinstated?
               Tenant::LeaveRequestsMailer.reinstated(leave_request)
             end

      unless mail.nil? || mail.from.nil? || mail.to.nil?
        mail.deliver         
      else
        false
      end
    end
    
  end
end
