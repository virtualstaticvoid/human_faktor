require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('accounts') {|key| assert_valid accounts(key) }
  end
  
  # NB: internet connection to S3 required 
  test "attach logo" do
    account = accounts(:one)
    account.logo = File.new(File.join(FIXTURES_DIR, 'logo.png'), 'r')
    assert account.save
  end

end
