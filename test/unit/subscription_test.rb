require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('subscriptions') {|key| assert_valid subscriptions(key) }
  end

  test "provides accessor for getting price by country" do
    assert subscriptions(:free).price_for(Country.default)
  end

  test "provides accessor for getting price_over_threshold by country" do
    assert subscriptions(:free).price_over_threshold_for(Country.default)
  end

end
