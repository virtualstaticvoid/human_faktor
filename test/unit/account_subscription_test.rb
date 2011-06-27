require 'test_helper'

class AccountSubscriptionTest < ActiveSupport::TestCase

  test "fixture data valid" do
    account_subscriptions.each {|record| assert_valid record }
  end

end
