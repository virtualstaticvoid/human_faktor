require 'test_helper'

module Tenant
  class LeaveRequestsControllerTest < ActionController::TestCase

    setup do
      @leave_request = leave_requests(:one)
      @leave_request_attributes = @leave_request.attributes.merge!({ 
        "identifier" => TokenHelper.friendly_token,
        "approver_comment" => 'Test comment by approver'
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
      sign_in_as :employee
      assert @leave_request.confirm!
      assert @leave_request.status == LeaveRequest::STATUS_PENDING
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    test "should get edit when status is approved" do
      sign_in_as :employee
      @leave_request.confirm
      assert @leave_request.approve!(employees(:admin), '')
      assert @leave_request.status == LeaveRequest::STATUS_APPROVED

      assert_equal false, @leave_request.approved_declined_by.nil?
      assert_equal false, @leave_request.approved_declined_at.nil?

      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    test "should get edit when status is declined" do
      sign_in_as :employee
      @leave_request.confirm
      assert @leave_request.decline!(employees(:admin), '')
      assert @leave_request.status == LeaveRequest::STATUS_DECLINED

      assert_equal false, @leave_request.approved_declined_by.nil?
      assert_equal false, @leave_request.approved_declined_at.nil?

      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    test "should get edit when status is cancelled" do
      sign_in_as :employee
      @leave_request.confirm
      assert @leave_request.approve(employees(:admin), '')
      assert @leave_request.cancel!(@leave_request.employee)
      assert @leave_request.status == LeaveRequest::STATUS_CANCELLED

      assert_equal false, @leave_request.cancelled_by.nil?
      assert_equal false, @leave_request.cancelled_at.nil?
      
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    test "should get edit when status is reinstated" do
      sign_in_as :employee
      @leave_request.confirm
      assert @leave_request.approve(employees(:admin), '')
      assert @leave_request.cancel(@leave_request.employee)
      assert @leave_request.reinstate!(@leave_request.approver)

      assert_equal false, @leave_request.reinstated_by.nil?
      assert_equal false, @leave_request.reinstated_at.nil?
      
      assert @leave_request.status == LeaveRequest::STATUS_REINSTATED
      get :edit, :tenant => @account.subdomain, :id => @leave_request.to_param
      assert_response :success
    end

    [:admin, :manager, :approver].each do |role|

      test "should approve for #{role}" do
        sign_in_as role
        assert @leave_request.confirm!
        assert @leave_request.status == LeaveRequest::STATUS_PENDING
        put :approve, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
        assert_redirected_to dashboard_path(:tenant => @account.subdomain)
      end

      test "should decline for #{role}" do
        sign_in_as role
        assert @leave_request.confirm!
        assert @leave_request.status == LeaveRequest::STATUS_PENDING
        put :decline, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
        assert_redirected_to dashboard_path(:tenant => @account.subdomain)
      end

      test "should cancel for #{role}" do
        sign_in_as role
        assert @leave_request.confirm!
        assert @leave_request.status == LeaveRequest::STATUS_PENDING
        put :cancel, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
        assert_redirected_to dashboard_path(:tenant => @account.subdomain)
      end
    
      test "should reinstate for #{role}" do
        sign_in_as role
        @leave_request.confirm
        assert @leave_request.cancel!(@leave_request.employee)
        assert @leave_request.status == LeaveRequest::STATUS_CANCELLED
        put :reinstate, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
        assert_redirected_to dashboard_path(:tenant => @account.subdomain)
      end

    end

    test "cannot approve for employee" do
      sign_in_as :employee
      assert @leave_request.confirm!
      assert @leave_request.status == LeaveRequest::STATUS_PENDING
      put :approve, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
      assert_redirected_to dashboard_path(:tenant => @account.subdomain)
    end

    test "cannot decline for employee" do
      sign_in_as :employee
      assert @leave_request.confirm!
      assert @leave_request.status == LeaveRequest::STATUS_PENDING
      put :decline, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
      assert_redirected_to dashboard_path(:tenant => @account.subdomain)
    end

    test "cannot cancel for employee" do
      sign_in_as :employee
      @leave_request.confirm
      assert @leave_request.approve!(@leave_request.approver, '')
      assert @leave_request.status == LeaveRequest::STATUS_APPROVED
      put :cancel, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
      assert_redirected_to dashboard_path(:tenant => @account.subdomain)
    end

    test "cannot reinstate for employee" do
      sign_in_as :employee
      @leave_request.confirm
      assert @leave_request.cancel!(@leave_request.employee)
      assert @leave_request.status == LeaveRequest::STATUS_CANCELLED
      put :reinstate, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
      assert_redirected_to dashboard_path(:tenant => @account.subdomain)
    end

    test "employee can cancel own leave" do
      sign_in_as :employee
      assert @leave_request.employee == employees(:employee)
      assert @leave_request.confirm!
      assert @leave_request.status == LeaveRequest::STATUS_PENDING
      put :cancel, :tenant => @account.subdomain, :id => @leave_request.to_param, :leave_request => @leave_request_attributes
      assert_redirected_to dashboard_path(:tenant => @account.subdomain)
    end

    test "should get balance with no parameters" do
      sign_in_as :employee
      get :balance, :format => :js, :tenant => @account.subdomain
      assert_response :success
    end

    test "should get balance with all parameters" do
      sign_in_as :employee
      get :balance, :format => :js, 
                    :tenant => @account.subdomain,
                    :employee => employees(:employee).id,
                    :leave_type => @account.leave_type_annual,
                    :date_from => Date.today,
                    :half_day_from => '0',
                    :date_to => Date.today + 4,
                    :half_day_to => '0',
                    :unpaid => '0'
      assert_response :success
    end

    test "should get balance for subordinate employee" do
      sign_in_as :admin
      get :balance, :format => :js, 
                    :tenant => @account.subdomain,
                    :employee => employees(:employee).id,
                    :leave_type => @account.leave_type_annual,
                    :date_from => Date.today,
                    :half_day_from => '0',
                    :date_to => Date.today + 4,
                    :half_day_to => '0',
                    :unpaid => '0'
      assert_response :success
    end
    
    test "cannot get balance for non-subordinate employee" do
      sign_in_as :employee
      get :balance, :format => :js, 
                    :tenant => @account.subdomain,
                    :employee => employees(:employee1).id,
                    :leave_type => @account.leave_type_annual,
                    :date_from => Date.today,
                    :half_day_from => '0',
                    :date_to => Date.today + 4,
                    :half_day_to => '0',
                    :unpaid => '0'
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end

  end
end

