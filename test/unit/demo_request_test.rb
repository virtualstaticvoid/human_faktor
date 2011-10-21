require 'test_helper'

class DemoRequestTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('demo_requests') {|key| assert_valid demo_requests(key) }
  end

end
