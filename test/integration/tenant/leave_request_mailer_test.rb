require 'test_helper'

module Tenant

  class LeaveRequestMailerTest < ActionDispatch::IntegrationTest
    fixtures :all

    test "should perform work" do
      leave_request = leave_requests(:one)
      leave_request.confirm!  # ensure confirmed

      assert LeaveRequestMailer.new(leave_request.id).perform()
      assert !ActionMailer::Base.deliveries.empty?
    end

  end
  
end
