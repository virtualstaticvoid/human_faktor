module Tenant
  class EmployeeMailer < Struct.new(:employee_id)
    
    def perform()
      employee = Employee.find(employee_id)
      mail = Tenant::EmployeesMailer.activate(employee)
      mail.deliver unless mail.nil? || mail.from.nil? || mail.to.nil?        
    end
    
  end
end

