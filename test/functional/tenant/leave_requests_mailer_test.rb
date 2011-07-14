require 'test_helper'

module Tenant
  class LeaveRequestsMailerTest < ActionMailer::TestCase

    setup do
      @leave_request = leave_requests(:one)
      @account = @leave_request.account
    end

    test "pending" do
      @leave_request.confirm!

      mail = LeaveRequestsMailer.pending(@leave_request)
      assert_equal "#{AppConfig.title} - #{@account.title} - New Leave Request", mail.subject
      assert_equal [@leave_request.approver.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

    test "approved" do
      @leave_request.confirm
      @leave_request.approve!(@leave_request.approver, '')

      mail = LeaveRequestsMailer.approved(@leave_request)
      assert_equal "#{AppConfig.title} - #{@account.title} - Leave Approved", mail.subject
      assert_equal [@leave_request.employee.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

    test "declined" do
      @leave_request.confirm
      @leave_request.decline!(@leave_request.approver, '')

      mail = LeaveRequestsMailer.declined(@leave_request)
      assert_equal "#{AppConfig.title} - #{@account.title} - Leave Declined", mail.subject
      assert_equal [@leave_request.employee.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

    test "cancelled" do
      @leave_request.confirm
      @leave_request.approve(@leave_request.approver, '')
      @leave_request.cancel!(@leave_request.employee)

      mail = LeaveRequestsMailer.cancelled(@leave_request)
      assert_equal "#{AppConfig.title} - #{@account.title} - Leave Cancelled", mail.subject
      assert_equal [@leave_request.approver.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

    test "reinstated" do
      @leave_request.confirm
      @leave_request.approve(@leave_request.approver, '')
      @leave_request.cancel(@leave_request.employee)
      @leave_request.reinstate!(@leave_request.approver)

      mail = LeaveRequestsMailer.reinstated(@leave_request)
      assert_equal "#{AppConfig.title} - #{@account.title} - Leave Reinstated", mail.subject
      assert_equal [@leave_request.employee.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

  end
end
