require 'test_helper'

module Tenant
  class DataFeedsControllerTest < ActionController::TestCase

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
    
    end

  end
end
