require 'date'
require 'informal'
require 'action_view/helpers/text_helper'
require 'heat_map_color_support'

class HeatMapEnquiry
  include Informal::Model
  
  attr_reader :account
  validates_presence_of :account
  
  attr_reader :employee
  validates_presence_of :employee

  attr_accessor :enquiry
  validates_presence_of :enquiry
  
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
  
  def initialize(account, employee)
    @account = account
    @employee = employee
    @filter_by = 'none'
    @enquiry = Base.default_enquiry
    @leave_requests_by_employee = {}
  end
  
  def enquiry_types
    Base.enquiry_types
  end
  
  def enquiry_type
    constantize(@enquiry)
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

  def leave_requests_for(employee)
    @leave_requests_by_employee[employee] ||= collect_leave_requests_for(employee)
  end

  def json
    self.enquiry_type.new(self).json
  end
  
  class Base
    include ActionView::Helpers::TextHelper
    
    @@enquiry_types = []
  
    def self.inherited(klass)
      @@enquiry_types << klass
    end
    
    def self.enquiry_types
      @@enquiry_types
    end
    
    def self.default_enquiry
      # assumes the first registered enquiry is the default
      @@enquiry_types[0].name
    end

    def self.display_name
      # look up name in the locales file
      I18n.t(self.name.gsub(/HeatMapEnquiry::/, '').underscore, :scope => 'heat_map_enquries')
    end

    attr_reader :criteria
    
    def initialize(criteria)
      @criteria = criteria
    end
    
    def json
      throw :not_implemented
    end
    
    protected
    
    def build_employee(employee, heat, parent_id = '', &block)
      build_item(
        "_#{parent_id}#{employee.to_param}",
        employee.full_name,
        1,
        heat,
        employee.full_name, 
        &block
      )
    end

    def build_leave_requests(query, count, parent_id)
      json = ""
      query.each do |leave_request|
        json << build_item(
          "_#{parent_id}_#{leave_request.to_param}",
          leave_request.to_s,
          leave_request.duration,
          count,
          leave_request.to_s
        )
      end
      json
    end
    
    def build_item(id, name, area, heat, title)
      json = "{"
      json << "  'id': '#{id}',"
      json << "  'name': '#{name}',"
      json << "  'data': { '$area': #{area}, '$color': '#{heat_map_color(heat)}', 'title': '#{title}' },"
      json << "  'children': ["
      json << yield if block_given?
      json << "  ]"
      json << "},"
    end
    
    def heat_map_color(value)
      HeatMapColorSupport.color_for(value).to_s
    end
    
  end
  
  # implement heat map enquiries
  class LeaveRequestsByEmployee < Base
    def json
      json = ""
      self.criteria.employees.each do |employee|
        leave_requests = self.criteria.leave_requests_for(employee)
        count = leave_requests.count()
        json << build_employee(employee, count) do
          build_leave_requests(leave_requests, count, employee.to_param)          
        end
      end
      json
    end
  end

  class LeaveRequestsByDuration < Base
    def json
      json = ""
      self.criteria.employees.each do |employee|
        leave_requests = self.criteria.leave_requests_for(employee)
        duration = leave_requests.sum(:duration)
        json << build_employee(employee, duration) do
          build_leave_requests(leave_requests, duration, employee.to_param)          
        end
      end
      json
    end
  end

  class UnpaidLeaveRequests < Base
    def json
      json = ""
      self.criteria.employees.each do |employee|
        leave_requests = self.criteria.leave_requests_for(employee).where(:unpaid => true)
        count = leave_requests.count()
        json << build_employee(employee, count) do
          build_leave_requests(leave_requests, count, employee.to_param)          
        end
      end
      json
    end
  end

  module LeaveConstraints
    require 'leave_constraints'
  
    attr_reader :constraint

    def json
      throw :constraint_not_set if constraint.nil?
      json = ""
      self.criteria.employees.each do |employee|
        leave_requests = self.leave_requests_query(employee)
        duration = leave_requests.sum(:duration)
        json << build_employee(employee, duration) do
          build_leave_requests(leave_requests, duration, employee.to_param)          
        end
      end
      json
    end
    
    def leave_requests_query(employee)
      self.criteria.leave_requests_for(employee).where(self.constraint.as_constraint_override => true)
    end
  
  end

#  class LeaveRequiringSupportingDocumentsNotProvided < Base
#    include LeaveConstraints
#
#    def initialize(criteria)
#      @constraint = 
#      super
#    end
#  end

  class LeaveExceedingRequiredNoticePeriod < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :exceeds_number_of_days_notice_required
      super
    end
  end

  class LeaveExceedingMinDaysPerRequest < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :exceeds_minimum_number_of_days_per_request
      super
    end
  end

  class LeaveExceedingMaxDaysPerRequest < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :exceeds_maximum_number_of_days_per_request
      super
    end
  end

  class LeaveExceedingCycleAllowance < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :exceeds_leave_cycle_allowance
      super
    end
  end

  class LeaveExceedingPermittedNegativeBalance < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :exceeds_negative_leave_balance
      super
    end
  end

  class LeaveExceedingMaxPermittedFutureDate < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :exceeds_maximum_future_date
      super
    end
  end

  class LeaveExceedingMaxPermittedBackDate < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :exceeds_maximum_back_date
      super
    end
  end

  class UnscheduledLeave < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :is_unscheduled
      super
    end
  end

  class UnscheduledLeaveAdjacentToWeekend < UnscheduledLeave
    include LeaveConstraints

    def leave_requests_query(employee)
      super.where(:is_adjacent.as_constraint_override => true)
    end
    
  end

  class UnscheduledLeaveByDepartment < Base
    def json
      # TODO
    end
  end

  class UnscheduledLeaveByLocation < Base
    def json
      # TODO
    end
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
        errors.add(:base) << 'Location required.' unless self.location_id.present? && self.account.locations.exists?(self.location_id)
      when 'department' then
        errors.add(:base) << 'Department required.' unless self.department_id.present? && self.account.departments.exists?(self.department_id)
      when 'employee' then
        errors.add(:base) << 'Employee required.' if !self.employee_id.present? || self.account.employees.find_by_identifier(self.employee_id).nil?
      else
        # ignore...
    end
  end

  def collect_leave_requests_for(employee)
    employee.leave_requests
            .active
            .where(
              ' (date_from BETWEEN :date_from AND :date_to) OR (date_to BETWEEN :date_from AND :date_to) ',
              { :date_from => self.date_from, :date_to => self.date_to }
            )
  end

  def constantize(string)
    names = string.split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
    end
    constant
  end
  
end
