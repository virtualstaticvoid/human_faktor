class EmployeeObserver < ActiveRecord::Observer

  def after_create(employee)
    Resque.enqueue(EmployeeMailer, employee.id)
  end

  def after_update(employee)
    # TODO
  end

  def after_delete(employee)
    # TODO
  end

end
