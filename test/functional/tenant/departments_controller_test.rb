require 'test_helper'

module Tenant
  class DepartmentsControllerTest < ActionController::TestCase
    setup do
      sign_in_as :admin
      @department = departments(:one)
      @department_attributes = @department.attributes.merge!({ 
        "title" => 'test'
      })
    end

    test "should get index" do
      get :index, :tenant => @account.subdomain
      assert_response :success
      assert_not_nil assigns(:departments)
    end

    test "should get new" do
      get :new, :tenant => @account.subdomain
      assert_response :success
    end

    test "should create department" do
      assert_difference('Department.count') do
        post :create, :tenant => @account.subdomain, :department => @department_attributes
      end

      assert_redirected_to departments_path(:tenant => @account.subdomain)
    end

    test "should get edit" do
      get :edit, :tenant => @account.subdomain, :id => @department.to_param
      assert_response :success
    end

    test "should update department" do
      put :update, :tenant => @account.subdomain, :id => @department.to_param, :department => @department.attributes
      assert_redirected_to departments_path(:tenant => @account.subdomain)
    end

    test "should destroy department" do
      assert_difference('Department.count', -1) do
        delete :destroy, :tenant => @account.subdomain, :id => @department.to_param
      end

      assert_redirected_to departments_path(:tenant => @account.subdomain)
    end
  end
end
