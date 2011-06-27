require 'test_helper'

class AccountProvisionerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should perform work" do
    registration = registrations(:one)
    
    account = AccountProvisioner.perform(registration.id)

    registration.reload

    assert_equal false, account.nil?
    assert_equal true, registration.active
    assert_equal registration.subdomain, account.subdomain
    assert_equal registration.title, account.title
    assert_equal registration.country, account.country
    assert_equal registration.partner, account.partner
    assert_equal true, account.active
    assert_equal 1, account.account_subscriptions.count
    
  end

end
