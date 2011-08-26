class EmployeeObserver < ActiveRecord::Observer

  def after_create(employee)
    Resque.enqueue(Tenant::EmployeeMailer, employee.id)
  end

end
