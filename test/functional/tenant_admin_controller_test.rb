require 'test_helper'

class TenantAdminControllerTest < ActionController::TestCase

  setup do
    @account = accounts(:one)
    @employee = employees(:admin1)
  end

  test "should redirect to tenant admin sign in" do
    get :index
    assert_redirected_to new_tenant_admin_session_url()
  end

  test "should get index" do
    admin_sign_in_as :admin
    get :index
    assert_response :success
  end

  test "should get show" do
    admin_sign_in_as :admin
    get :show, :id => @account.to_param
    assert_response :success
  end

  test "should get impersonate" do
    admin_sign_in_as :admin
    get :impersonate, :id => @employee.to_param
    assert_redirected_to dashboard_url(:tenant => @account.subdomain)
  end

end
