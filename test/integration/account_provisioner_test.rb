require 'test_helper'

class AccountProvisionerTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should perform work" do
    registration = registrations(:one)
    
    account = AccountProvisioner.perform(registration.id)

    registration.reload

    assert_equal true, registration.active

    assert_equal false, account.nil?
    assert account.valid?
    
    assert_equal registration.subdomain, account.subdomain
    assert_equal registration.title, account.title
    assert_equal registration.country, account.country
    assert_equal registration.auth_token, account.auth_token
    assert_equal false, account.active
    assert_equal false, account.location.nil?
    assert_equal false, account.department.nil?
   
    assert_equal 1, account.account_subscriptions.count
    assert_equal 1, account.locations.count
    assert_equal 1, account.departments.count
    
  end

end
