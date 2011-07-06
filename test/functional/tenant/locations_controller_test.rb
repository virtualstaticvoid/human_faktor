require 'test_helper'

module Tenant
  class LocationsControllerTest < ActionController::TestCase
    setup do
      sign_in_as :admin
      @location = locations(:one)
      @location_attributes = @location.attributes.merge!({ 
        "title" => 'test'
      })
    end

    test "should get index" do
      get :index, :tenant => @account.subdomain
      assert_response :success
      assert_not_nil assigns(:locations)
    end

    test "should get new" do
      get :new, :tenant => @account.subdomain
      assert_response :success
    end

    test "should create location" do
      assert_difference('Location.count') do
        post :create, :tenant => @account.subdomain, :location => @location_attributes
      end

      assert_redirected_to locations_path(:tenant => @account.subdomain)
    end

    test "should get edit" do
      get :edit, :tenant => @account.subdomain, :id => @location.to_param
      assert_response :success
    end

    test "should update location" do
      put :update, :tenant => @account.subdomain, :id => @location.to_param, :location => @location.attributes
      assert_redirected_to locations_path(:tenant => @account.subdomain)
    end

    test "should destroy location" do
      assert_difference('Location.count', -1) do
        delete :destroy, :tenant => @account.subdomain, :id => @location.to_param
      end

      assert_redirected_to locations_path(:tenant => @account.subdomain)
    end
  end
end
