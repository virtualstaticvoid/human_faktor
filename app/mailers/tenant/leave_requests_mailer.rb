module Tenant
  class LeaveRequestsMailer < BaseMailer

    def pending(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(:to => leave_request.approver.email, :subject => "#{@account.title} New Leave Request") if leave_request.approver.notify?
    end

    def approved(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(:to => leave_request.employee.email, :subject => "#{@account.title} Leave Approved") if leave_request.employee.notify?
    end

    def declined(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(:to => leave_request.employee.email, :subject => "#{@account.title} Leave Declined") if leave_request.employee.notify?  
    end

    def cancelled(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(:to => leave_request.approver.email, :subject => "#{@account.title} Leave Cancelled") if leave_request.approver.notify?
    end

  end
end

