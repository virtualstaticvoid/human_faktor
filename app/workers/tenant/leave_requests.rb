class Tenant::LeaveRequests
  @queue = :leave_requests_queue
  
  def self.perform(leave_request_id)

    # TODO  

  end
  
end
