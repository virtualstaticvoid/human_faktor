require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  test "fixture data valid" do
    locations.each {|record| assert_valid record }
  end

end
