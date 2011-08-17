class EmployeeMailer
  @queue = :"#{AppConfig.subdomain}_medium"
  
  def self.perform(employee_id)
    # TODO  
  end
  
end
