require 'test_helper'

module Tenant
  class LeaveRequestsMailerTest < ActionMailer::TestCase

    setup do
      @leave_request = leave_requests(:one)
      @account = @leave_request.account
    end

    test "pending" do
      mail = LeaveRequestsMailer.pending(@leave_request)
      assert_equal "#{@account.title} New Leave Request", mail.subject
      assert_equal [@leave_request.approver.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

    test "approved" do
      mail = LeaveRequestsMailer.approved(@leave_request)
      assert_equal "#{@account.title} Leave Approved", mail.subject
      assert_equal [@leave_request.employee.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

    test "declined" do
      mail = LeaveRequestsMailer.declined(@leave_request)
      assert_equal "#{@account.title} Leave Declined", mail.subject
      assert_equal [@leave_request.employee.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

    test "cancelled" do
      mail = LeaveRequestsMailer.cancelled(@leave_request)
      assert_equal "#{@account.title} Leave Cancelled", mail.subject
      assert_equal [@leave_request.approver.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

  end
end
