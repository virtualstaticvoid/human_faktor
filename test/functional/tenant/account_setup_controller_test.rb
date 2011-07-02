require 'test_helper'

module Tenant
  class AccountSetupControllerTest < ActionController::TestCase
  
    test "should get index" do
      get :index, :tenant => @account.subdomain, :token => @account.auth_token
      assert_response :success
    end
    
    # TODO
  
  end
end

