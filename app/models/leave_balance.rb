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
  
  def self.find_leave_balance(account, employee, leave_type, date_as_at)
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
