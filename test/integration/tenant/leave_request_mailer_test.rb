require 'test_helper'

module Tenant

  class LeaveRequestMailerTest < ActionDispatch::IntegrationTest
    fixtures :all

    test "should perform work when status pending" do
      leave_request = leave_requests(:one)
      leave_request.confirm!  # ensure confirmed

      assert LeaveRequestMailer.new(leave_request.id).perform()
      assert !ActionMailer::Base.deliveries.empty?
    end

    test "should perform work when status approved" do
      leave_request = leave_requests(:one)
      leave_request.confirm
      leave_request.approve!(leave_request.approver, '')

      assert LeaveRequestMailer.new(leave_request.id).perform()
      assert !ActionMailer::Base.deliveries.empty?
    end

    test "should perform work when status declined" do
      leave_request = leave_requests(:one)
      leave_request.confirm
      leave_request.decline!(leave_request.approver, '')

      assert LeaveRequestMailer.new(leave_request.id).perform()
      assert !ActionMailer::Base.deliveries.empty?
    end

    test "should perform work when status cancelled" do
      leave_request = leave_requests(:one)
      leave_request.confirm
      leave_request.approve(leave_request.approver, '')
      leave_request.cancel!(leave_request.approver)

      assert LeaveRequestMailer.new(leave_request.id).perform()
      assert !ActionMailer::Base.deliveries.empty?
    end

    test "should perform work when status reinstated" do
      leave_request = leave_requests(:one)
      leave_request.confirm
      leave_request.approve(leave_request.approver, '')
      leave_request.cancel(leave_request.approver)
      leave_request.reinstate!(leave_request.approver)

      assert LeaveRequestMailer.new(leave_request.id).perform()
      assert !ActionMailer::Base.deliveries.empty?
    end

  end
  
end
