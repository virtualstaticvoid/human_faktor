require "informal"

class AccountSetup
  include Informal::Model
  
  #default_values 

  attr_accessor :admin_first_name
  attr_accessor :admin_last_name
  attr_accessor :admin_user_name
  attr_accessor :admin_password
  attr_accessor :admin_password_confirmation
  attr_accessor :admin_email
  
  attr_accessor :fixed_daily_hours

  attr_accessor :leave_cycle_start_date

  LeaveType.for_each_leave_type do |leave_type_class|
    leave_type_name = leave_type_class.name.gsub(/LeaveType::/, '').downcase
    attr_accessor "#{leave_type_name}_leave_allowance"
  end
  
  attr_accessor :auth_token_confirmation

  def save(account)
    ActiveRecord::Base.transaction do 
    
      # create administrator
      administrator = account.employees.build(
        :user_name => self.admin_user_name,
        :password => self.admin_password,
        :password_confirmation => self.admin_password_confirmation,
        :role => 'admin',
        :first_name => self.admin_first_name,
        :last_name => self.admin_last_name,
        :email => self.admin_email
      )
      
      # defaults
      account.fixed_daily_hours = self.fixed_daily_hours
      
      # leave policies
      LeaveType.for_each_leave_type do |leave_type_class|
        leave_type_name = leave_type_class.name.gsub(/LeaveType::/, '').downcase
      
        leave_type = account.send("leave_type_#{leave_type_name}")
        leave_type.cycle_start_date = self.leave_cycle_start_date
        leave_type.cycle_days_allowance = self.send("#{leave_type_name}__leave_allowance")
        
      end
    
    end
  
    # TODO
    false
  
  end

end
