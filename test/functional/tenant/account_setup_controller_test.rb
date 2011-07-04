require 'test_helper'

module Tenant
  class AccountSetupControllerTest < ActionController::TestCase

    setup do
      # HACK: needs to match auth_token of account
      registration = registrations(:one)
      registration.send(:write_attribute, :auth_token, @account.auth_token)
      registration.save!
    end
  
    test "should get edit" do
      get :edit, :tenant => @account.subdomain, :token => @account.auth_token
      assert_response :success
    end
    
    test "should update" do
    
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

        LeaveType.for_each_leave_type do |leave_type_class|
          leave_type_name = leave_type_class.name.gsub(/LeaveType::/, '').downcase

          leave_type = @account.send("leave_type_#{leave_type_name}")
          setup.send("#{leave_type_name}_leave_allowance=", leave_type.cycle_days_allowance)
        end

        setup.auth_token = @account.auth_token
        setup.auth_token_confirmation = @account.auth_token
      end
    
      put :update, :tenant => @account.subdomain, :account_setup => account_setup.attributes
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end
  
  end
end

