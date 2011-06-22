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

  test "should create registration" do
    registration = registrations(:one)
    assert_difference('Registration.count') do
      post :create, :registration => @registration_attributes
    end
    assert_redirected_to registration_path(assigns(:registration))
  end

  test "should show registration" do
    get :show, :id => @registration.to_param
    assert_response :success
  end

end
