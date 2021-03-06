require 'date'
require 'informal'

class StaffBalanceEnquiry
  include Informal::Model
  
  attr_reader :account
  validates_presence_of :account

  attr_reader :employee
  validates_presence_of :employee
  
  attr_accessor :date_as_at
  validates :date_as_at, :timeliness => { :type => :date }
  
  attr_accessor :leave_type_id
  validates :leave_type_id, :presence => true
  
  def leave_type
    @leave_type ||= (@account.leave_types.find(self.leave_type_id) || @account.leave_types.annual)
  end
  
  attr_accessor :filter_by
  validates :filter_by, :inclusion => { :in => %w{none location department employee} }
  
  attr_accessor :location_id
  attr_accessor :department_id
  attr_accessor :employee_id

  validate :filter_by_item_id
  
  def attributes
    {
      :date_as_at => self.date_as_at,
      :leave_type_id => self.leave_type_id,
      :filter_by => self.filter_by,
      :location_id => self.location_id,
      :department_id => self.department_id,
      :employee_id => self.employee_id
    }
  end

  def initialize(account, employee)
    @account = account
    @employee = employee
    @leave_type_id = account.leave_types.annual.id
    @filter_by = 'none'
  end

  def employees
    case self.filter_by
      when 'location' then
        self.employee.staff.select { |employee| employee.location_id == self.location_id.to_i }
      when 'department' then
        self.employee.staff.select { |employee| employee.department_id == self.department_id.to_i }
      when 'employee' then
        employee = self.account.employees.find_by_identifier(self.employee_id)
        employee.nil? ? [] : [employee]
      else
        self.employee.staff
    end
  end
  
  private
  
  def filter_by_item_id
    case self.filter_by
      when 'location' then
        errors.add(:base, 'Location required.') unless self.location_id.present? && self.account.locations.exists?(self.location_id)
      when 'department' then
        errors.add(:base, 'Department required.') unless self.department_id.present? && self.account.departments.exists?(self.department_id)
      when 'employee' then
        errors.add(:base, 'Employee required.') if !self.employee_id.present? || self.account.employees.find_by_identifier(self.employee_id).nil?
      else
        # ignore...
    end
  end
  
end

