require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  
  setup do
    @registration = registrations(:one)
    @registration_attributes = @registration.attributes.merge({
      :identifier => TokenHelper.friendly_token,
      :subdomain => 'clientx',
      :auth_token => TokenHelper.friendly_token
    })    
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get new with partner" do
    partner_id = partners(:one).id
    get :new, :partner => partner_id
    assert_response :success
    assert_equal partner_id, assigns(:registration).partner_id
  end

  test "should create registration" do
    assert_difference('Registration.count') do
      post :create, :registration => @registration_attributes
    end
    assert_redirected_to account_registration_path(assigns(:registration))
  end

  test "should show registration" do
    get :show, :id => @registration.to_param
    assert_response :success
  end

  test "should query registration" do
    get :query, :id => @registration.to_param, :started => Time.now.to_s, :format => :js
    assert_response :success
  end

end
