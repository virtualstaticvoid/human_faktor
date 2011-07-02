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
  attr_accessor :annual_leave_allowance  
  attr_accessor :educational_leave_allowance  
  attr_accessor :medical_leave_allowance  
  attr_accessor :maternity_leave_allowance  
  attr_accessor :compassionate_leave_allowance  

  attr_accessor :auth_token_confirmation

  def save(account)
  
    # TODO
    false
  
  end

end
