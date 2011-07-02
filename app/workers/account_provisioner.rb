require 'date'

class AccountProvisioner
  @queue = :account_provisioner_queue
  
  def self.perform(registration_id)
  
    registration = Registration.find(registration_id)
    
    # create the account in a transaction
    new_account = ActiveRecord::Base.transaction do
    
      # create account
      account = Account.create(
        :subdomain => registration.subdomain,
        :title => registration.title,
        :theme => AppConfig.default_theme,
        :auth_token => registration.auth_token,
        :country => registration.country,
        :active => false
      )
      
      # subscription
      subscription = registration.subscription

      #  calculate the start and end dates of the subscription
      from_date = Date.today
      to_date = Date.new(from_date.year, from_date.month + 1, 1) >> subscription.duration
      
      AccountSubscription.create(
        :account => account,
        :from_date => from_date,
        :to_date => to_date,
        :title => subscription.title, 
        :price => subscription.price, 
        :max_employees => subscription.max_employees,
        :threshold => subscription.threshold, 
        :price_over_threshold => subscription.price_over_threshold
      )
      
      # default location and department
      account.location = account.locations.build(:title => 'Default')
      account.department = account.departments.build(:title => 'Default')
      
      # leave types
      cycle_start_date = Date.new(Date.today.year, 1, 1)
      
      create_leave_type account, :annual,         365,  21, 5, cycle_start_date, 10
      create_leave_type account, :educational,    365,   3, 0, cycle_start_date,  0, { :employee_capture_allowed => false }
      create_leave_type account, :medical,       1095,   9, 0, cycle_start_date,  0, { :requires_documentation => true, :requires_documentation_after => 2 }
      create_leave_type account, :maternity,      365, 120, 0, cycle_start_date,  0
      create_leave_type account, :compassionate,  365,   3, 0, cycle_start_date,  0
      
      # save all changes
      account.save!
      
      # make the registration is active
      registration.update_attribute(:active, true)
      
      account
      
    end

    # send welcome email
    RegistrationsMailer.completed(registration).deliver

    new_account

  end
  
  private 
  
  def self.create_leave_type(account, type_symbol, cycle_duration, cycle_days_allowance, cycle_days_carry_over, cycle_start_date, max_negative_balance, options = {})
    
    leave_type_class = LeaveType.type_from(type_symbol)
    
    account.leave_types << leave_type = leave_type_class.create(
    
      :cycle_start_date => cycle_start_date,
      :cycle_duration => cycle_duration,
      :cycle_duration_unit => LeaveType::DURATION_UNIT_YEARS,
      :cycle_days_allowance => cycle_days_allowance,
      :cycle_days_carry_over => cycle_days_carry_over,

      :employee_capture_allowed => options[:employee_capture_allowed] || true,
      :approver_capture_allowed => true,
      :admin_capture_allowed => true,

      :approval_required => true,

      :requires_documentation => options[:requires_documentation] || false,
      :requires_documentation_after => options[:requires_documentation_after] || 1,
      :required_days_notice => 1,
      :unscheduled_leave_allowed => options[:unscheduled_leave_allowed] || true,
      :max_days_for_future_dated => options[:max_days_for_future_dated] || 365,
      :max_days_for_back_dated => options[:max_days_for_back_dated] || 365,
      :min_days_per_single_request => 1,
      :max_days_per_single_request => options[:max_days_per_single_request] || 30,
      :required_days_notice => options[:required_days_notice] || 1,
      :max_negative_balance => max_negative_balance
    )
    
    leave_type
  end
  
end
