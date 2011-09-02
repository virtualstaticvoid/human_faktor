require 'test_helper'

module Tenant

  class LeaveRequestMailerTest < ActionDispatch::IntegrationTest
    fixtures :all

    test "should perform work" do
      leave_request = leave_requests(:one)

      LeaveRequestMailer.new(leave_request.id).perform()

      # TODO: assert that an email was sent
      assert !ActionMailer::Base.deliveries.empty?

    end

  end
  
end
