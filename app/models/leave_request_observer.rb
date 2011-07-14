class LeaveRequestObserver < ActiveRecord::Observer

  def after_update(leave_request)
    Resque.enqueue(LeaveRequestMailer, leave_request.id)
  end

end
