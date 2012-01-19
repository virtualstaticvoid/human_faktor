class LeaveRequestObserver < ActiveRecord::Observer

  def after_create(leave_request)
    LeaveRequestDay.create_for(leave_request)    
    WorkQueue.enqueue(Tenant::LeaveRequestMailer, leave_request.id)
  end

  def after_update(leave_request)
    LeaveRequestDay.update_for(leave_request)    
    WorkQueue.enqueue(Tenant::LeaveRequestMailer, leave_request.id) if leave_request.changed.include?('status')
  end

  def after_delete(leave_request)
    LeaveRequestDay.destroy_for(leave_request)    
  end

end
