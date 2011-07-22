require 'test_helper'

module Tenant
  class ProfileControllerTest < ActionController::TestCase
    setup do
      sign_in_as :employee
      @employee = employees(:employee)
    end

    test "should get edit" do
      get :edit, :tenant => @account.subdomain, :id => @employee.to_param
      assert_response :success
    end

    test "should update employee" do
      put :update, :tenant => @account.subdomain, :id => @employee.to_param, :employee => @employee.attributes
      assert_redirected_to profile_path(:tenant => @account.subdomain)
    end

  end
end
