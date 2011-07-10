require 'test_helper'

class AccountSetupTest < ActiveSupport::TestCase

  setup do
    @account = accounts(DEFAULT_ACCOUNT)
    # HACK: needs to match auth_token of account
    registration = registrations(:one)
    registration.send(:write_attribute, :auth_token, @account.auth_token)
    registration.save!
  end

  test "should fail validation" do
    assert_equal false, AccountSetup.new().valid?
  end

  test "should appear to be persisted" do
    assert AccountSetup.new().persisted?
  end
  
  test "should save" do
    
    registration = @account.registration

    account_setup = AccountSetup.new().tap do |setup|
      setup.admin_first_name = registration.first_name
      setup.admin_last_name = registration.last_name
      setup.admin_user_name = registration.user_name
      setup.admin_email = registration.email
      setup.admin_password = 'sekret123'
      setup.admin_password_confirmation = 'sekret123'
      
      setup.fixed_daily_hours = @account.fixed_daily_hours
      setup.leave_cycle_start_date = Date.new(Date.today.year, 1, 1)

      LeaveType.for_each_leave_type_name do |leave_type_name|
        leave_type = @account.send("leave_type_#{leave_type_name}")
        setup.send("#{leave_type_name}_leave_allowance=", leave_type.cycle_days_allowance)
      end

      setup.auth_token = @account.auth_token
      setup.auth_token_confirmation = @account.auth_token
    end

    # should save    
    assert account_setup.save(@account)
    
    # account should be active
    @account.reload
    assert @account.active
    
  end

end

