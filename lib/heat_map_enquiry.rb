require 'date'
require 'informal'
require 'action_view/helpers/text_helper'
require 'heat_map_color_support'
require 'leave_constraints'

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
  
  def color_table
    self.enquiry_type.new(self).color_table
  end
  
  module ColorSchemes
    module RedWhite
      def init_colors
        @color_from = '#E0E0E0'
        @color_to = '#FF0000'
      end
    end
    
    module BlueGreen
      def init_colors
        @color_from = '#007F00'
        @color_to = '#00007F'
      end
    end
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
      init_colors
      set_color_map(0, 100)
    end
    
    include ColorSchemes::RedWhite  # default colors
    
    def json
      throw :not_implemented
    end
    
    def set_color_map(min, max)
      @color_map = HeatMapColorSupport.new(@color_from, @color_to, min, max)
    end
    
    def color_table
      @color_map.color_table
    end
    
    protected

    def build_location(location, area, heat, &block)
      build_titled_item(location, area, heat, &block)
    end

    def build_department(department, area, heat, &block)
      build_titled_item(department, area, heat, &block)
    end
    
    def build_employee(employee, heat, parent_id = '', &block)
      build_item(
        "_#{parent_id}_#{employee.to_param}",
        employee.full_name,
        1,
        heat,
        "#{employee.to_s} (#{heat.round(2)})", 
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
      @color_map.color_for(value).to_s
    end
    
    private 
    
    def build_titled_item(item, area, heat, &block)
      build_item(
        "_#{item.to_param}",
        item.title,
        area,
        heat,
        "#{item.to_s} (#{heat.round(2)})", 
        &block
      )
    end

  end
  
  # support module for the bulk of heat map types...
  module LeaveRequestsByEmployeeBase
    
    def load_json(employees, leave_requests_func, measure_func, parent_id = '')
    
      data = build_employees_data(employees, leave_requests_func, measure_func)
      
      self.set_color_map(
        data.inject(0) {|result, point| result > point[1] ? point[1] : result  } || 0,
        data.inject(0) {|result, point| result < point[1] ? point[1] : result  } || 100
      )
      
      json = ""
      data.each do |employee, measure, leave_requests|
        json << build_employee(employee, measure, parent_id) do
          build_leave_requests(leave_requests, measure, "_#{parent_id}_#{employee.to_param}")          
        end
      end
      json
    
    end
    
    def build_employees_data(employees, leave_requests_func, measure_func)
      data = []
      employees.each do |employee|
        leave_requests = leave_requests_func.call(employee)
        measure = measure_func.call(leave_requests)
        data << [employee, measure, leave_requests]
      end
      data
    end
    
  end

  # implement heat map enquiries
  class LeaveRequestsByEmployee < Base
    include LeaveRequestsByEmployeeBase
    include ColorSchemes::BlueGreen
    
    def json
      load_json self.criteria.employees,
                lambda {|employee| self.criteria.leave_requests_for(employee) },
                lambda {|leave_requests| leave_requests.count() }
    end
  end

  class LeaveRequestsByDuration < Base
    include LeaveRequestsByEmployeeBase
    include ColorSchemes::BlueGreen
    
    def json
      load_json self.criteria.employees,
                lambda {|employee| self.criteria.leave_requests_for(employee) },
                lambda {|leave_requests| leave_requests.sum(:duration) }
    end
  end

  class UnpaidLeaveRequests < Base
    include LeaveRequestsByEmployeeBase
    
    def json
      load_json self.criteria.employees,
                lambda {|employee| self.criteria.leave_requests_for(employee).where(:unpaid => true) },
                lambda {|leave_requests| leave_requests.count() }
    end
  end

  # support module for heat maps based on leave constraints
  #  default measure by count!
  module LeaveConstraints
    include LeaveRequestsByEmployeeBase
  
    attr_reader :constraint

    def json
      throw :constraint_not_set if constraint.nil?
    
      load_json self.criteria.employees,
                lambda {|employee| self.leave_requests_query(employee) },
                lambda {|leave_requests| self.heat_measure(leave_requests) }
    end
    
    def leave_requests_query(employee)
      self.criteria.leave_requests_for(employee).where(self.constraint.as_constraint_override => true)
    end
    
    def heat_measure(leave_requests)
      leave_requests.count()
    end
  
  end

  class LeaveRequiringSupportingDocumentsNotProvided < Base
    include LeaveConstraints

    def initialize(criteria)
      @constraint = :requires_documentation
      super
    end
    
    def leave_requests_query(employee)
      # TODO: ignore requests where the document has been subsequently provided
      #  see issue#2, issue#91 and issue#104
      super
    end
    
  end

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

    # override to use duration as measure    
    def heat_measure(leave_requests)
      leave_requests.sum(:duration)
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
    
    # TODO: muliplier logic

    def initialize(criteria)
      @constraint = :is_unscheduled
      super
    end

    # override to use duration as measure    
    def heat_measure(leave_requests)
      leave_requests.sum(:duration)
    end
    
  end

  class UnscheduledLeaveAdjacentToWeekend < UnscheduledLeave
    include LeaveConstraints

    def leave_requests_query(employee)
      # add on additional constraint
      super.where(:is_adjacent.as_constraint_override => true)
    end

    # override to apply additional filtering logic
    def heat_measure(leave_requests)
      
      # 
      # needs to be count of days within request that are adjacent to w/end or holiday
      #  i.e. If next to a mon and thur (holiday) and sat, then = 3
      #
    
      super
    end

  end
  
  class UnscheduledLeaveByDepartment < Base
    include LeaveRequestsByEmployeeBase
  
    def json
      
      employees = self.criteria.employees
      
      # group employees by department
      departments = self.criteria.account.departments.inject({}) {|list, department| 
        list[department] = employees.select {|employee| employee.department_id == department.id } 
        list
      }
      
      # calculate leave durations per employee
      leave_requests = {}
      leave_request_durations = {}

      employees.each do |employee|
        leave_requests[employee] = self.criteria
                                    .leave_requests_for(employee)
                                    .where(:is_unscheduled.as_constraint_override => true)
        leave_request_durations[employee] = leave_requests[employee].sum(:duration)
      end
      
      # calculate weighted duration per department
      department_meta = {}

      departments.each do |department, employees|
        duration = employees.inject(0) {|result, employee| result += leave_request_durations[employee] }
        department_meta[department] = [
          employees.length, 
          employees.length > 0 ? (duration.to_f / employees.length.to_f) : 0    # weighted duration
        ]
      end

      # calculate min & max values for department color table
      min_heat = department_meta.inject(0) {|result, entry| result > entry[1][1] ? entry[1][1] : result  } || 0
      max_heat = department_meta.inject(0) {|result, entry| result < entry[1][1] ? entry[1][1] : result  } || 100
      
      json = ""
      departments.each do |department, employees|
        
        # reset color map (TODO: refactor!)
        self.set_color_map(min_heat, max_heat)
        
        area, heat = department_meta[department]
        
        json << build_department(department, area <= 0 ? 1 : (1 + area), heat) do

          load_json employees,
                    lambda {|employee| leave_requests[employee] },
                    lambda {|leave_requests| leave_requests.sum(:duration) },
                    department.to_param

        end
      
      end
      json
      
    end
    
  end

  class UnscheduledLeaveByLocation < Base
    include LeaveRequestsByEmployeeBase
  
    def json
      
      employees = self.criteria.employees
      
      # group employees by location
      locations = self.criteria.account.locations.inject({}) {|list, location| 
        list[location] = employees.select {|employee| employee.location_id == location.id } 
        list
      }
      
      # calculate leave durations per employee
      leave_requests = {}
      leave_request_durations = {}

      employees.each do |employee|
        leave_requests[employee] = self.criteria
                                    .leave_requests_for(employee)
                                    .where(:is_unscheduled.as_constraint_override => true)
        leave_request_durations[employee] = leave_requests[employee].sum(:duration)
      end
      
      # calculate weighted duration per location
      location_meta = {}

      locations.each do |location, employees|
        duration = employees.inject(0) {|result, employee| result += leave_request_durations[employee] }
        location_meta[location] = [
          employees.length, 
          employees.length > 0 ? (duration.to_f / employees.length.to_f) : 0    # weighted duration
        ]
      end

      # calculate min & max values for location color table
      min_heat = location_meta.inject(0) {|result, entry| result > entry[1][1] ? entry[1][1] : result  } || 0
      max_heat = location_meta.inject(0) {|result, entry| result < entry[1][1] ? entry[1][1] : result  } || 100
      
      json = ""
      locations.each do |location, employees|
        
        # reset color map (TODO: refactor!)
        self.set_color_map(min_heat, max_heat)
        
        area, heat = location_meta[location]
        
        json << 
        build_location(location, area <= 0 ? 1 : (1 + area), heat) do

          load_json employees,
                    lambda {|employee| leave_requests[employee] },
                    lambda {|leave_requests| leave_requests.sum(:duration) },
                    location.to_param

        end
      
      end
      json
      
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
