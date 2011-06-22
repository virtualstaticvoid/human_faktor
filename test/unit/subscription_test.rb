require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

  test "fixture data valid" do
    subscriptions.each {|record| assert_valid record }
  end

end
