require 'test_helper'

module Tenant
  class LeaveTypesControllerTest < ActionController::TestCase

    test "should redirect to home_sign_in" do
      get :edit, :tenant => 'non-existent'
      assert_redirected_to home_sign_in_url
    end

    test "should redirect to employee_sign_in" do
      get :edit, :tenant => @account.subdomain
      assert_redirected_to new_employee_session_url(:tenant => @account.subdomain)
    end
    
    [:manager, :approver, :employee].each do |role|
    
      test "should redirect to dashboard if #{role}" do
        sign_in_as role
        get :edit, :tenant => @account.subdomain
        assert_redirected_to dashboard_url(:tenant => @account.subdomain)
      end
    
    end

    test "should get edit for admin" do
      sign_in_as :admin
      get :edit, :tenant => @account.subdomain
      assert_response :success
    end
    
    test "should update for admin" do
      sign_in_as :admin
      post :update, :tenant => @account.subdomain, :account => @account.attributes
      assert_redirected_to edit_leave_types_url(:tenant => @account.subdomain)
    end

  end
end
