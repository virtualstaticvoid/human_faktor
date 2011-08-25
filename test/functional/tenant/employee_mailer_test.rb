require 'test_helper'

module Tenant
  class EmployeeMailerTest < ActionMailer::TestCase

    setup do
      @employee = employees(:employee)
      @account = @employee.account
    end

    test "activate" do
      mail = EmployeeMailer.activate(@employee)
      assert_equal "#{AppConfig.title} - #{@account.title} - Employee Activation", mail.subject
      assert_equal [@employee.email], mail.to
      assert_equal [AppConfig.no_reply_email], mail.from
      #assert_match "Hi", mail.body.encoded
    end

  end
end
