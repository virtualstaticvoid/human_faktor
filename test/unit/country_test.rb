require 'test_helper'

class CountryTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('countries') {|key| assert_valid countries(key) }
  end

  test "can locate by iso code" do
    assert Country.by_iso_code('za')
  end

end
