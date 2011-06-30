require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  test "fixture data valid" do
    accounts.each {|record| assert_valid record }
  end
  
  test "attach logo" do
    account = accounts(:one)
    account.logo = File.new(File.join(FIXTURES_DIR, 'logo.png'), 'r')
    assert account.save
  end

end
