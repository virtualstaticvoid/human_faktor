class LeaveRequestObserver < ActiveRecord::Observer

  def after_create(leave_request)
    Resque.enqueue(Tenant::LeaveRequestMailer, leave_request.id)
  end

  def after_update(leave_request)
    Resque.enqueue(Tenant::LeaveRequestMailer, leave_request.id)
  end

end
