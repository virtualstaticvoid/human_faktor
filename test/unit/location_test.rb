require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('locations') {|key| assert_valid locations(key) }
  end

end
