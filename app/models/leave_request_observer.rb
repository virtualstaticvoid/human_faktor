class LeaveRequestObserver < ActiveRecord::Observer

  def after_create(leave_request)
    WorkQueue.enqueue(Tenant::LeaveRequestMailer, leave_request.id)
  end

  def after_update(leave_request)
    WorkQueue.enqueue(Tenant::LeaveRequestMailer, leave_request.id) if leave_request.changed.include?('status')
  end

end
