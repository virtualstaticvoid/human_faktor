class LeaveRequestFilter < DateFilter

  attr_reader :account
  validates_presence_of :account

  attr_reader :employee
  validates_presence_of :employee

  attr_accessor :filter_by
  validates :filter_by, :inclusion => { :in => %w{none location department employee} }
  
  attr_accessor :location_id
  attr_accessor :department_id
  attr_accessor :employee_id

  validate :filter_by_item_id

  attr_accessor :requires_documentation_only
  
  def attributes
    {
      :date_from => self.date_from,
      :date_to => self.date_to,
      :filter_by => self.filter_by,
      :location_id => self.location_id,
      :department_id => self.department_id,
      :employee_id => self.employee_id,
      :requires_documentation_only => self.requires_documentation_only,
      :status => self.status
    }
  end

  def initialize(account, employee)
    @account = account
    @employee = employee
    @filter_by = 'none'
    @requires_documentation_only = false
    @status = LeaveRequest::STATUS_PENDING
  end
  
  def status
    @status
  end
  def status=(value)
    @status = value.to_i
  end
  
  def leave_request_status
    case @status
      when LeaveRequest::FILTER_STATUS_APPROVED # used?
        LeaveRequest::APPROVED_STATUSES
      when LeaveRequest::FILTER_STATUS_ACTIVE
        LeaveRequest::ACTIVE_STATUSES
      else 
        @status
    end
  end
  
  def status?(status)
    @status == status
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
