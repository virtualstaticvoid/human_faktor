module Tenant
  class EmployeesMailer < BaseMailer

    def activate(employee)
      @account = employee.account
      @employee = employee
      
      # ensure there the authentication token
      @employee.ensure_authentication_token!
      
      mail(
        :to => employee.email, 
        :subject => "#{AppConfig.title} - #{@account.title} - Employee Activation"
      ) if employee.active? && employee.notify?
    end

  end
end

