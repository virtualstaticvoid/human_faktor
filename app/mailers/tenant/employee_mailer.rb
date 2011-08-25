module Tenant
  class EmployeeMailer < BaseMailer

    def activate(employee)
      @account = employee.account
      @employee = employee
      mail(
        :to => employee.email, 
        :subject => "#{AppConfig.title} - #{@account.title} - Employee Activation"
      ) if employee.active? && employee.notify?
    end

  end
end

