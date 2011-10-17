class EmployeeFilter
  include Informal::Model

  attr_reader :account
  validates_presence_of :account

  attr_accessor :filter_by
  validates :filter_by, :inclusion => { :in => %w{none location department employee} }
  
  attr_accessor :location_id
  attr_accessor :department_id
  attr_accessor :employee_id

  validate :filter_by_item_id
  
  def attributes
    {
      :filter_by => self.filter_by,
      :location_id => self.location_id,
      :department_id => self.department_id,
      :employee_id => self.employee_id
    }
  end

  def initialize(account)
    @account = account
    @filter_by = 'none'
  end

  def employees
    employees = self.account.employees
    case self.filter_by
      when 'location' then
        employees = employees.where(:location_id => self.location_id.to_i)
      when 'department' then
        employees = employees.where(:department_id => self.department_id.to_i)
      when 'employee' then
        employees = employees.where(:id => self.employee_id)
      else
        employees  
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