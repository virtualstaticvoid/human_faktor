require 'test_helper'

module Tenant
  class DataFeedsControllerTest < ActionController::TestCase

    [:calendar_entries, :leave_requests, :employee_staff].each do |action|

      test "should redirect to home_sign_in for #{action}" do
        get action, :tenant => 'non-existent'
        assert_redirected_to home_sign_in_url
      end

      test "should redirect to employee_sign_in for #{action}" do
        get action, :tenant => @account.subdomain
        assert_redirected_to new_employee_session_url(:tenant => @account.subdomain)
      end
    
    end

    Employee::ROLES.each do |role|

      test "should get calendar entries as #{role}" do
        sign_in_as role
        get :calendar_entries, :tenant => @account.subdomain, :format => :json
        assert_response :success
      end

      test "should get leave requests as #{role}" do
        sign_in_as role
        get :leave_requests, :tenant => @account.subdomain, :format => :json
        assert_response :success
      end
    
      test "should get employee staff as #{role}" do
        sign_in_as role
        get :employee_staff, :tenant => @account.subdomain, :format => :json
        assert_response :success
      end

    end

  end
end
