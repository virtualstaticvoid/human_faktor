require 'test_helper'

module Tenant

  class LeaveRequestMailerTest < ActionDispatch::IntegrationTest
    fixtures :all

    test "should perform work" do
      leave_request = leave_requests(:one)

      LeaveRequestMailer.perform(leave_request.id)

      # TODO: assert that an email was sent

    end

  end
  
end
