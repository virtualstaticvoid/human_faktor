require 'test_helper'

class AccountSubscriptionTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('account_subscriptions') {|key| assert_valid account_subscriptions(key) }
  end

end
