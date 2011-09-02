class EmployeeObserver < ActiveRecord::Observer

  def after_create(employee)
    WorkQueue.enqueue(Tenant::EmployeeMailer, employee.id)
  end

end
