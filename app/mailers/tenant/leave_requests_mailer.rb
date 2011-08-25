module Tenant
  class LeaveRequestsMailer < BaseMailer

    def pending(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(
        :to => leave_request.approver.email, 
        :subject => "#{AppConfig.title} - #{@account.title} - New Leave Request"
      ) if leave_request.approver.notify?
    end

    def approved(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(
        :to => leave_request.employee.email, 
        :subject => "#{AppConfig.title} - #{@account.title} - Leave Approved"
      ) if leave_request.employee.notify?
    end

    def declined(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(
        :to => leave_request.employee.email, 
        :subject => "#{AppConfig.title} - #{@account.title} - Leave Declined"
      ) if leave_request.employee.notify?  
    end

    def cancelled(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(
        :to => leave_request.approver.email, 
        :subject => "#{AppConfig.title} - #{@account.title} - Leave Cancelled"
      ) if leave_request.approver.notify?
    end

    def reinstated(leave_request)
      @account = leave_request.account
      @leave_request = leave_request
      mail(
        :to => leave_request.employee.email, 
        :subject => "#{AppConfig.title} - #{@account.title} - Leave Reinstated"
      ) if leave_request.employee.notify?
    end

  end
end

