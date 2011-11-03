require 'test_helper'

class SubscriptionCountryTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('subscription_countries') {|key| assert_valid subscription_countries(key) }
  end

  test "should provide helper for accessing a subscription's prices for a country" do
    assert SubscriptionCountry.prices_for(subscriptions(:small), countries(:za))
  end

  test "reverts to subscription's prices if no entry found" do
    subscription = subscriptions(:small)
    subscription_country = SubscriptionCountry.prices_for(subscription, Country.new(:id => 0))
    assert_equal subscription.price, subscription_country.price
    assert_equal subscription.price_over_threshold, subscription_country.price_over_threshold
  end

end
