require 'test_helper'

module Tenant
  class EmployeesControllerTest < ActionController::TestCase
    setup do
      sign_in_as :admin
      @employee = employees(:test)
      @employee_attributes = @employee.attributes.merge!({ 
        "identifier" => TokenHelper.friendly_token,
        "user_name" => 'test.user',
        "email" => 'unique@human-faktor.com'
      })
    end

    test "should get index" do
      get :index, :tenant => @account.subdomain
      assert_response :success
      assert_not_nil assigns(:employees)
    end

    test "should get index.js" do
      get :index, :format => :js, :tenant => @account.subdomain
      assert_response :success
      assert_not_nil assigns(:employees)
    end

    test "should post filtered" do
      post :filtered, :tenant => @account.subdomain, :format => :js
      assert_response :success
      assert_not_nil assigns(:employees)
    end

    test "should get index filtered by location" do
      get :index, :tenant => @account.subdomain, :employee_filter => { :filter_by => 'location', :location_id => @account.locations.first.id }
      assert_response :success
      assert_not_nil assigns(:employees)
    end

    test "should get index filtered by department" do
      get :index, :tenant => @account.subdomain, :employee_filter => { :filter_by => 'department',:department_id => @account.departments.first.id }
      assert_response :success
      assert_not_nil assigns(:employees)
    end

    test "should get index filtered by employee (not currently used)" do
      get :index, :tenant => @account.subdomain, :employee_filter => { :filter_by => 'employee',:employee_id => @employee.id }
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

    test "should get balance" do
      get :balance, :tenant => @account.subdomain, :id => @employee.to_param, :format => :js
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

    test "should reactivate employee" do
      put :reactivate, :tenant => @account.subdomain, :id => @employee.to_param
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
