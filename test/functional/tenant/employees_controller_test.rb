require 'test_helper'

module Tenant
  class EmployeesControllerTest < ActionController::TestCase
    setup do
      sign_in_as :admin
      @employee = employees(:test)
      @employee_attributes = @employee.attributes.merge!({ 
        "identifier" => TokenHelper.friendly_token,
        "user_name" => 'test.user'
      })
    end

    test "should get index" do
      get :index, :tenant => @account.subdomain
      assert_response :success
      assert_not_nil assigns(:employees)
    end

    test "should get new" do
      get :new, :tenant => @account.subdomain
      assert_response :success
    end

    test "should create employee" do
      assert_difference('Employee.count') do
        post :create, :tenant => @account.subdomain, :employee => @employee_attributes
      end

      assert_redirected_to employees_path(:tenant => @account.subdomain)
    end

    test "should get edit" do
      get :edit, :tenant => @account.subdomain, :id => @employee.to_param
      assert_response :success
    end

    test "should update employee" do
      put :update, :tenant => @account.subdomain, :id => @employee.to_param, :employee => @employee.attributes
      assert_redirected_to employees_path(:tenant => @account.subdomain)
    end
    
    test "should deactivate employee" do
      put :deactivate, :tenant => @account.subdomain, :id => @employee.to_param
      assert_redirected_to employees_path(:tenant => @account.subdomain)
    end

    test "should destroy employee" do
      assert_difference('Employee.count', -1) do
        delete :destroy, :tenant => @account.subdomain, :id => @employee.to_param
      end

      assert_redirected_to employees_path(:tenant => @account.subdomain)
    end
  end
end
