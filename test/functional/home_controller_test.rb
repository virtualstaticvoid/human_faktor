require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get contact" do
    get :contact
    assert_response :success
  end

  test "should get terms" do
    get :terms
    assert_response :success
  end

  test "should get features" do
    get :features
    assert_response :success
  end

  test "should get subscriptions" do
    get :subscriptions
    assert_response :success
  end

  test "should get partner" do
    get :partner
    assert_response :success
  end

end
