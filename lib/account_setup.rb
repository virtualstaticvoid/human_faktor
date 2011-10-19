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
  validates :admin_password, :presence => true, :confirmation => true, :length => { :in => 5..20 }

  attr_accessor :admin_email
  validates :admin_email, :presence => true, :email => true

  attr_accessor :fixed_daily_hours
  validates :fixed_daily_hours, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }

  attr_accessor :leave_cycle_start_date
  validates :leave_cycle_start_date, :timeliness => { :type => :date}

  LeaveType.for_each_leave_type_name do |leave_type_name|
    attr_accessor :"#{leave_type_name}_leave_allowance"
    validates :"#{leave_type_name}_leave_allowance", :numericality => { :greater_than_or_equal_to => 1 }
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
        :email => self.admin_email,
        :notify => true,
        :active => true,

        # NB: ensure belongs to default location and department
        :location => account.location,
        :department => account.department
      )
      
      # defaults
      account.fixed_daily_hours = self.fixed_daily_hours
      
      # leave policies
      LeaveType.for_each_leave_type_name do |leave_type_name|
      
        leave_type = account.send("leave_type_#{leave_type_name}")
        leave_type.cycle_start_date = self.leave_cycle_start_date
        leave_type.cycle_days_allowance = self.send("#{leave_type_name}_leave_allowance")
        
        valid &= leave_type.save
        
      end
      
      # activate account
      account.active = true
      
      valid &= administrator.save(:validate => false)   # save ~ ignore any validation errors
      valid &= account.save
      
      # make admin own approver
      administrator.update_attributes(
        :approver => administrator
      )
      valid &= administrator.save(:validate => false)   # save ~ ignore any validation errors
      
    end if valid
  
    valid
  end

  # needed for form to work as expected
  def persisted?
    true
  end
  
  def attributes
    attributes = {
      :admin_first_name => self.admin_first_name,
      :admin_last_name => self.admin_last_name,
      :admin_user_name => self.admin_user_name,
      :admin_password => self.admin_password,
      :admin_email => self.admin_email,
      :fixed_daily_hours => self.fixed_daily_hours,
      :leave_cycle_start_date => self.leave_cycle_start_date,
      :auth_token => self.auth_token,
      :auth_token_confirmation => self.auth_token_confirmation
    }
    
    LeaveType.for_each_leave_type_name do |leave_type_name|
      attributes[:"#{leave_type_name}_leave_allowance"] = self.send("#{leave_type_name}_leave_allowance")
    end
    
    attributes
  end

end
