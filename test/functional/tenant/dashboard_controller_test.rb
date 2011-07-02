require 'test_helper'

module Tenant
  class DashboardControllerTest < ActionController::TestCase

    test "should redirect to home_sign_in" do
      get :index, :tenant => 'non-existent'
      assert_redirected_to home_sign_in_url
    end

    test "should redirect to employee_sign_in" do
      get :index, :tenant => @account.subdomain
      assert_redirected_to new_employee_session_url(:tenant => @account.subdomain)
    end

    Employee::ROLES.each do |role|

      test "should get index as #{role}" do
        sign_in_as role
        get :index, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get profile as #{role}" do
        sign_in_as role
        get :profile, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get balance as #{role}" do
        sign_in_as role
        get :balance, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get calendar as #{role}" do
        sign_in_as role
        get :calendar, :tenant => @account.subdomain
        assert_response :success
      end

      # TODO: add additional actions

    end

    test "should redirect to calendar if employee requests staff calendar" do
      sign_in_as :employee
      get :staff_calendar, :tenant => @account.subdomain
      assert_redirected_to calendar_url(:tenant => @account.subdomain)
    end

    [:approver, :manager, :admin].each do |role|

      test "should get staff calendar for #{role}" do
        sign_in_as role
        get :staff_calendar, :tenant => @account.subdomain
        assert_response :success
      end

    end

  end
end
