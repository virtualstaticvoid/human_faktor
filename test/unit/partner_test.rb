require 'test_helper'

class PartnerTest < ActiveSupport::TestCase

  test "fixture data valid" do
    partners.each {|record| assert_valid record }
  end

end
