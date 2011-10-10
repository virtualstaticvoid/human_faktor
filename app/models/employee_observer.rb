class EmployeeObserver < ActiveRecord::Observer

  def after_create(employee)
    WorkQueue.enqueue(Tenant::EmployeeMailer, employee.id)
  end

  def after_update(employee)
    WorkQueue.enqueue(Tenant::EmployeeMailer, employee.id) if employee.changed.any? {|field| field == 'active' } && employee.active
  end

end
