require 'test_helper'

module Tenant
  class BulkUploadsControllerTest < ActionController::TestCase
    setup do
      @bulk_upload = bulk_uploads(:one)
      @bulk_upload_attributes = @bulk_upload.attributes.merge!({ 
        "comment" => 'Yet another upload'
      })
    end

    test "should redirect to home_sign_in" do
      get :new, :tenant => 'non-existent'
      assert_redirected_to home_sign_in_url
    end

    test "should redirect to employee_sign_in" do
      get :new, :tenant => @account.subdomain
      assert_redirected_to new_employee_session_url(:tenant => @account.subdomain)
    end

    [:manager, :approver, :employee].each do |role|
    
      test "should redirect to dashboard if #{role}" do
        sign_in_as role
        get :new, :tenant => @account.subdomain
        assert_redirected_to dashboard_url(:tenant => @account.subdomain)
      end
    
    end
    
    test "should get new for admin" do
      sign_in_as :admin
      get :new, :tenant => @account.subdomain
      assert_response :success
    end
    
    test "should create bulk upload" do
      sign_in_as :admin
      assert_difference('BulkUpload.count', 1) do
        post :create, :tenant => @account.subdomain, :bulk_upload => @bulk_upload_attributes
      end

      assert_redirected_to bulk_upload_url(assigns(:bulk_upload), :tenant => @account.subdomain)
    end

    test "should show bulk upload" do
      sign_in_as :admin
      get :show, :id => @bulk_upload.to_param, :tenant => @account.subdomain
      assert_response :success
    end
    
    test "should edit bulk upload" do
      sign_in_as :admin
      get :edit, :id => @bulk_upload.to_param, :tenant => @account.subdomain
      assert_response :success
    end

    # TODO: simulate state changes

    test "should update bulk upload" do
      put :update, :tenant => @account.subdomain, :id => @bulk_upload.to_param, :bulk_upload => @bulk_upload.attributes
      assert_redirected_to bulk_upload_url(assigns(:bulk_upload), :tenant => @account.subdomain)
    end

    test "should destory bulk upload" do
      sign_in_as :admin
      assert_difference('BulkUpload.count', -1) do
        delete :destroy, :id => @bulk_upload.to_param, :tenant => @account.subdomain
      end

      assert_redirected_to account_url(:tenant => @account.subdomain)
    end

  end
end
