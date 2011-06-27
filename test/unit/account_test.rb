require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  test "fixture data valid" do
    accounts.each {|record| assert_valid record }
  end

end
