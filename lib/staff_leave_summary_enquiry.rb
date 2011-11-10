require 'date'
require 'informal'

class StaffLeaveSummaryEnquiry
  include Informal::Model
  
  attr_reader :account
  validates_presence_of :account

  attr_reader :employee
  validates_presence_of :employee
  
  attr_accessor :date_from
  validates :date_from, :timeliness => { :type => :date }
  
  attr_accessor :date_to
  validates :date_to, :timeliness => { :type => :date }
  
  attr_accessor :filter_by
  validates :filter_by, :inclusion => { :in => %w{none location department employee} }
  
  attr_accessor :location_id
  attr_accessor :department_id
  attr_accessor :employee_id

  validate :date_from_must_occur_before_date_to, 
           :date_to_must_occur_after_date_from,
           :duration_at_least_one_month,
           :filter_by_item_id

  def attributes
    {
      :date_from => self.date_from,
      :date_to => self.date_to,
      :filter_by => self.filter_by,
      :location_id => self.location_id,
      :department_id => self.department_id,
      :employee_id => self.employee_id
    }
  end

  def initialize(account, employee)
    @account = account
    @employee = employee
    @filter_by = 'none'
  end

  def date_range
    (self.date_from..self.date_to)
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

  def summary_for(employee, leave_type)

    self.account
        .leave_requests
        .approved
        .where(:employee_id => employee.id, :leave_type_id => leave_type.id)
        .sum(:duration)

  end
  
  private
  
  def date_from_must_occur_before_date_to
    errors.add(:date_from, "can't be after the to date") if
      !(date_from.blank? || date_to.blank?) && (date_from > date_to)
  end

  def date_to_must_occur_after_date_from
    errors.add(:date_to, "can't be before the from date") if
      !(date_from.blank? || date_to.blank?) && (date_to < date_from)
  end

  def duration_at_least_one_month
    errors.add(:base, "Date window needs to be at least 7 days") if (date_to - date_from) < 7
  end
  
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