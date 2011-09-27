require 'test_helper'

class PartnerTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('partners') {|key| assert_valid partners(key) }
  end

end
