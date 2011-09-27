require 'test_helper'

class CountryTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('countries') {|key| assert_valid countries(key) }
  end

end
