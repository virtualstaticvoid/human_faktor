class LeaveBalance < ActiveRecord::Base
  include AccountScopedModel

  default_scope order('date_as_at DESC')

  belongs_to :employee
  belongs_to :leave_type

  validates :employee, :existence => true, :uniqueness => { :scope => [:account_id, :leave_type_id, :date_as_at] }
  validates :leave_type, :existence => true, :uniqueness => { :scope => [:account_id, :employee_id, :date_as_at] }
  validates :date_as_at, :timeliness => { :type => :date }
  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }

end
