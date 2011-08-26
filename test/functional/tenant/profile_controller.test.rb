require 'test_helper'

module Tenant
  class ProfileControllerTest < ActionController::TestCase
    setup do
      sign_in_as :employee
      @employee = employees(:employee)
    end

    test "should get edit" do
      get :edit, :tenant => @account.subdomain
      assert_response :success
    end

    test "should update employee" do
      put :update, :tenant => @account.subdomain, :id => @employee.to_param, :employee => @employee.attributes
      assert_redirected_to profile_url(:tenant => @account.subdomain)
    end

    test "should activate" do
      @employee.update_attributes!(:password => nil, :password_confirmation => nil)
      get :activate, :tenant => @account.subdomain
      assert_redirected_to activate_url(:tenant => @account.subdomain)
    end

    test "should setactive" do
      put :setactive, :tenant => @account.subdomain, :employee => { :password => 'test123', :password_confirmation => 'test123' }
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end

    test "activate should redirect to dashboard if employee has a password" do
      @employee.update_attributes!(:password => 'test123', :password_confirmation => 'test123')
      get :activate, :tenant => @account.subdomain
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end

  end
end
