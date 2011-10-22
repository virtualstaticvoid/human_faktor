require 'test_helper'

module Tenant
  class BulkUploadStagesControllerTest < ActionController::TestCase

    setup do
      @bulk_upload = bulk_uploads(:one)
    end

    test "should redirect to home_sign_in" do
      get :index, :tenant => 'non-existent', :bulk_upload_id => @bulk_upload.to_param, :format => :js
      assert_redirected_to home_sign_in_url
    end

    test "should permission denied" do
      get :index, :tenant => @account.subdomain, :bulk_upload_id => @bulk_upload.to_param, :format => :js
      assert_response 401 # permission denied
    end

    [:manager, :approver, :employee].each do |role|
      test "should redirect to dashboard for #{role}" do
        sign_in_as role
        get :index, :tenant => @account.subdomain, :bulk_upload_id => @bulk_upload.to_param, :format => :js
        assert_redirected_to dashboard_url(:tenant => @account.subdomain)
      end
    end

    ['all', 'valid', 'errors'].each do |status|
      test "should get index for status #{status}" do
        sign_in_as :admin
        get :index, :tenant => @account.subdomain, :bulk_upload_id => @bulk_upload.to_param, :status => status, :format => :js
        assert_response :success
      end
    end

  end
end
