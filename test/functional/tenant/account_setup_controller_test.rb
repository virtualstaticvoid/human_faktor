require 'test_helper'

module Tenant
  class AccountSetupControllerTest < ActionController::TestCase

    setup do
      # HACK: needs to match auth_token of account
      registration = registrations(:one)
      registration.send(:write_attribute, :auth_token, @account.auth_token)
      registration.save!
    end
  
    test "should get edit" do
      get :edit, :tenant => @account.subdomain, :token => @account.auth_token
      assert_response :success
    end
    
    # TODO
  
  end
end

