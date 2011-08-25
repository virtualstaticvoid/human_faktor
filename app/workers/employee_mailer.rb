class EmployeeMailer
  @queue = :"#{AppConfig.subdomain}_medium"
  
  def self.perform(employee_id)
    employee = Employee.find(employee_id)
    mail = Tenant::EmployeeMailer.activate(leave_request)
    mail.deliver unless mail.nil? || mail.from.nil? || mail.to.nil?        
  end
  
end
