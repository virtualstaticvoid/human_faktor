require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  setup do
    @account = accounts(:one)
  end

  test "fixture data valid" do
    for_each_fixture ('accounts') {|key| assert_valid accounts(key) }
  end
  
  # NB: internet connection to S3 required 
  test "attach logo" do
    @account = accounts(:one)
    @account.logo = File.new(File.join(FIXTURES_DIR, 'logo.png'), 'r')
    assert @account.save
  end

  test "provides accessors for each leave type" do
    assert @account.leave_type_annual
    assert @account.leave_type_educational
    assert @account.leave_type_medical
    assert @account.leave_type_maternity
    assert @account.leave_type_compassionate
  end

end
