require 'test_helper'

class DemoRequestsControllerTest < ActionController::TestCase

  setup do
    @demo_request = demo_requests(:one) 
    @demo_request_attributes = @demo_request.attributes.merge({
      :identifier => TokenHelper.friendly_token
    })    
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create demo request" do
    assert_difference('DemoRequest.count') do
      post :create, :demo_request => @demo_request_attributes
    end
    assert_redirected_to root_url
  end

end
