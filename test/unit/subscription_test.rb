require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('subscriptions') {|key| assert_valid subscriptions(key) }
  end

end
