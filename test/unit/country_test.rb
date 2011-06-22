require 'test_helper'

class CountryTest < ActiveSupport::TestCase

  test "fixture data valid" do
    countries.each {|record| assert_valid record }
  end

end
