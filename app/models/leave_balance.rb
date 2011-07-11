class LeaveBalance < ActiveRecord::Base
  include AccountScopedModel

  belongs_to :employee
  belongs_to :leave_type

  validates :employee_id, :uniqueness => { :scope => [:account_id, :leave_type_id, :date_as_at] }
  validates :employee, :existence => true
  
  validates :leave_type_id, :uniqueness => { :scope => [:account_id, :employee_id, :date_as_at] }
  validates :leave_type, :existence => true
  
  validates :date_as_at, :timeliness => { :type => :date }
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }

  class << self
  
    def take_on_balance_for(employee, leave_type)
      LeaveBalance.where(
        :account_id => employee.account_id,
        :employee_id => employee.id,
        :leave_type_id => leave_type.id
      ).order(:date_as_at).first
    end
  
    def balance_for(employee, leave_type, date_as_at)
    
      # leave balance for this cycle
      
      # less unpaid leave
      
      # plus carry over from last cycle
      
      # less leave taken for cycle
      
      # less leave not yet taken up to date_as_at
    
      ##
      # inputs:
      #
      # * leave_type.cycle_start_date_of(date_as_at)
      #
      # * employee.leave_cycle_allocation(leave_type)
      # * employee.leave_cycle_carry_over(leave_type)
      # * employee.fixed_daily_hours_ratio
      #
      
      # attempt to find leave balance record
      #  - if not found, use the employee take on balance 
      
      0
    end
    
    def find_leave_balance(account, employee, leave_type, date_as_at)
    
      LeaveBalance.where(
        :account_id => account.id,
        :employee_id => employee.id,
        :leave_type_id => leave_type.id
      ).where(
        'date_as_at <= :date_as_at',
        { :date_as_at => date_as_at }
      ).order('date_as_at DESC').first
      
    end
  
  end
  
  class LeaveBalanceBreakDown
  end

end
