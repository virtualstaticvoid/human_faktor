require 'test_helper'

module Tenant
  class LeaveRequestsControllerTest < ActionController::TestCase

    setup do
      @leave_request = leave_requests(:annual)
      @leave_request_attributes = @leave_request.attributes.merge!({ 
        "identifier" => TokenHelper.friendly_token
      })
    end

    test "should redirect to home_sign_in" do
      get :edit, :tenant => 'non-existent', :id => @leave_request.to_param
      assert_redirected_to home_sign_in_url
    end

    test "should redirect to employee_sign_in" do
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_redirected_to new_employee_session_url(:tenant => @account.subdomain)
    end

    test "should get edit when status is new" do
      sign_in_as :employee
      assert @leave_request.status == LeaveRequest::STATUS_NEW
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    test "should get edit when status is pending" do
      @leave_request.confirm
      assert @leave_request.status == LeaveRequest::STATUS_APPROVED
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    test "should get edit when status is declined" do
      @leave_request.decline(employees(:admin), '')
      assert @leave_request.status == LeaveRequest::STATUS_DECLINED
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    test "should get edit when status is cancelled" do
      @leave_request.cancel
      assert @leave_request.status == LeaveRequest::STATUS_CANCELLED
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    [:admin, :manager, :approver].each do |role|

      test "should approve for #{role}" do
        sign_in_as role
        put :approve, :tenant => @account.subdomain, :id => @leave_request.to_param
        assert_redirected_to dashboard_path(:tenant => @account.subdomain)
      end

      test "should decline for #{role}" do
        sign_in_as role
        put :decline, :tenant => @account.subdomain, :id => @leave_request.to_param
        assert_redirected_to dashboard_path(:tenant => @account.subdomain)
      end

      test "should cancel for #{role}" do
        sign_in_as role
        put :cancel, :tenant => @account.subdomain, :id => @leave_request.to_param
        assert_redirected_to dashboard_path(:tenant => @account.subdomain)
      end
    
    end

    test "cannot approve for employee" do
      put :approve, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :failure
    end

    test "cannot decline for employee" do
      put :decline, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :failure
    end

    test "should cancel for employee" do
      put :cancel, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :failure
    end
    
  end
end

