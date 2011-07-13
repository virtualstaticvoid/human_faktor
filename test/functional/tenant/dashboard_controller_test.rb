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

      test "should get help as #{role}" do
        sign_in_as role
        get :help, :tenant => @account.subdomain
        assert_response :success
      end

      # NOTE: add additional actions here

    end

    test "should redirect to calendar if employee requests staff calendar" do
      sign_in_as :employee
      get :staff_calendar, :tenant => @account.subdomain
      assert_redirected_to calendar_url(:tenant => @account.subdomain)
    end

    test "should redirect to dashboard if employee requests staff leave carry over" do
      sign_in_as :employee
      get :staff_leave_carry_over, :tenant => @account.subdomain
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end

    test "should redirect to dashboard if employee requests problem staff" do
      sign_in_as :employee
      get :problem_staff, :tenant => @account.subdomain
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end

    [:approver, :manager, :admin].each do |role|

      test "should get staff calendar for #{role}" do
        sign_in_as role
        get :staff_calendar, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get problem staff for #{role}" do
        sign_in_as role
        get :problem_staff, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get staff leave carry over for #{role}" do
        sign_in_as role
        get :staff_leave_carry_over, :tenant => @account.subdomain
        assert_response :success
      end

    end

  end
end
