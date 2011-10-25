require 'test_helper'

module Tenant
  module LeaveRequestsControllerBaseTest

    def self.included(klass)
      klass.class_eval do

        setup do
          @leave_request = leave_requests(:one)
          @leave_request_attributes = @leave_request.attributes.merge!({ 
            "identifier" => TokenHelper.friendly_token,
            "date_from" => Date.new(2012, 2, 10),
            "date_to" => Date.new(2012, 2, 12)
          })
        end

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
            assert_not_nil assigns(:leave_requests)
          end

          [
            LeaveRequest::FILTER_STATUS_ACTIVE, 
            LeaveRequest::FILTER_STATUS_APPROVED, 
            LeaveRequest::STATUS_DECLINED,
            LeaveRequest::STATUS_CANCELLED
          ].each do |status|

            test "should get index as #{role} filtered by #{status}" do
              sign_in_as role
              get :index, :tenant => @account.subdomain, :status => status
              assert_response :success
              assert_not_nil assigns(:leave_requests)
            end

          end

          test "should get index as #{role} with date from" do
            sign_in_as role
            get :index, :tenant => @account.subdomain, :date_from => Date.new(2011, 1, 1)
            assert_response :success
            assert_not_nil assigns(:leave_requests)
          end

          test "should get index as #{role} with date to" do
            sign_in_as role
            get :index, :tenant => @account.subdomain, :date_to => Date.new(2011, 12, 31)
            assert_response :success
            assert_not_nil assigns(:leave_requests)
          end

          test "should get index as #{role} with date from and date to" do
            sign_in_as role
            get :index, :tenant => @account.subdomain, :date_from => Date.new(2011, 1, 1), :date_to => Date.new(2011, 12, 31)
            assert_response :success
            assert_not_nil assigns(:leave_requests)
          end

          test "should get new as #{role}" do
            sign_in_as role
            get :new, :tenant => @account.subdomain
            assert_response :success
          end

        end

        test "should get new with leave type, from and to parameters" do
          sign_in_as :employee
          get :new, {
            :tenant => @account.subdomain, 
            :leave_type => @leave_request.leave_type_id,
            :from => @leave_request.date_from, 
            :to => @leave_request.date_to
          }
          assert_response :success
          assert_equal @leave_request.leave_type_id, assigns(:leave_request).leave_type_id
          assert_equal @leave_request.date_from, assigns(:leave_request).date_from
          assert_equal @leave_request.date_to, assigns(:leave_request).date_to
        end

        test "should create leave_request" do
          sign_in_as :employee
          assert_difference('LeaveRequest.count') do
            post :create, :tenant => @account.subdomain, :leave_request => @leave_request_attributes
          end

          leave_request = assigns(:leave_request)
          if leave_request.has_constraint_violations?
            assert_redirected_to leave_request_url(leave_request, :tenant => leave_request.account.subdomain)
          else
            assert_redirected_to dashboard_url(:tenant => leave_request.account.subdomain)
          end

        end
      
      end
    end

  end
end
