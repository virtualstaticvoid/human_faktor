require "informal"

class AccountSetup
  include Informal::Model
  
  attr_accessor :admin_first_name
  validates :admin_first_name, :presence => true, :length => { :maximum => 100 }

  attr_accessor :admin_last_name
  validates :admin_last_name, :presence => true, :length => { :maximum => 100 }

  attr_accessor :admin_user_name
  validates :admin_user_name, :presence => true, :length => { :maximum => 20 }

  attr_accessor :admin_password
  validates :admin_password, :presence => true, :confirmation => true

  attr_accessor :admin_email
  validates :admin_email, :presence => true, :email => true

  attr_accessor :fixed_daily_hours
  validates :fixed_daily_hours, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }

  attr_accessor :leave_cycle_start_date
  validates :leave_cycle_start_date, :timeliness => { :type => :date}

  LeaveType.for_each_leave_type do |leave_type_class|
    leave_type_name = leave_type_class.name.gsub(/LeaveType::/, '').downcase
    attr_accessor "#{leave_type_name}_leave_allowance"
    validates "#{leave_type_name}_leave_allowance".to_sym, :numericality => { :greater_than_or_equal_to => 1 }
  end
  
  attr_accessor :auth_token
  validates :auth_token, :presence => true, :confirmation => true

  def save(account)
    valid = self.valid?
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
        leave_type.cycle_days_allowance = self.send("#{leave_type_name}_leave_allowance")
        
        valid &= leave_type.save
        
      end
      
      # activate account
      account.active = true
      
      valid &= administrator.save
      valid &= account.save
      
    end if valid
  
    valid
  end

  # needed for form to work as expected
  def persisted?
    true
  end

end
