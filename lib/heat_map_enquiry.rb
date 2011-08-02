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
  
  def initialize(account, employee)
    @account = account
    @employee = employee
    @enquiry = LeaveRequestsByEmployee.name
    @date_from = Date.today - 365
    @date_to = Date.today
  end
  
  def enquiry_types
    Base.enquiry_types
  end
  
  def enquiry_type
    constantize(@enquiry)
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
    
    attr_reader :account
    attr_reader :employee
    attr_reader :date_from
    attr_reader :date_to
    
    def initialize(criteria)
      @account = criteria.account
      @employee = criteria.employee
      @date_from = criteria.date_from
      @date_to = criteria.date_to
    end
    
    def json
      throw :not_implemented
    end
    
    protected
    
    def base_query
      @account
          .leave_requests
          .active
          .where('date_from BETWEEN :date_from AND :date_to', { :date_from => date_from, :date_to => date_to })
    end
    
    def data_item(id, name, area, heat, title)
      return <<JSON_DATA
{ 'id': '#{id}', 
  'name': '#{name}', 
  'data': { '$area': #{area}, '$color': '#{heat_map_color(heat)}', 'title': '#{title}' }, 
  'children': [#{yield if block_given?}] },
JSON_DATA
                
    end
  
    def build_employee_json(query, parent_id = '')
      json = ""
      query.group(:employee_id)
           .sum(:duration)
           .each do |employee_id, duration|
        
        employee = Employee.find(employee_id)
        
        json << data_item("_#{parent_id}_#{employee.to_param}", 
                          employee.full_name, 
                          duration, 
                          duration, 
                          employee.full_name) do
        
          build_leave_request_json(query.where(:employee_id => employee_id), "#{parent_id}_#{employee.to_param}")
        
        end
        
      end
      json
    end
  
    def build_leave_request_json(query, parent_id = '')
      json = ""
      query.each do |leave_request|
        json << data_item("_#{parent_id}_#{leave_request.to_param}", 
                          leave_request.to_s, 
                          leave_request.duration, 
                          leave_request.duration, 
                          "#{leave_request.leave_type} - #{leave_request.status_text} (#{pluralize(leave_request.duration, 'day')})")
      end
      json
    end
    
    def heat_map_color(value)
      HeatMapColorSupport.color_for(value).to_s
    end
    
  end
  
  class LeaveRequestsByEmployee < Base

    def self.display_name
      'Leave requests by employee'
    end

    def json
      build_employee_json(base_query)
    end

  end

  class LeaveRequestsByDuration < Base

    def self.display_name
      'Leave requests by duration'
    end

    def json
      json = ""
      base_query.group(:duration)
                .count().each do |duration, count|
            
        json << data_item("_#{duration}_", 
                          pluralize(duration, 'day'), 
                          duration, 
                          count, 
                          "#{pluralize(duration, 'day')}") do
          
          build_employee_json(base_query.where(:duration => duration), "#{duration}")
        
        end
        
      end
      json
    end

  end
  
  class LeaveRequestsUnpaid < Base

    def self.display_name
      'Unpaid leave requests'
    end

    def json
      build_employee_json(base_query.where(:unpaid => true))
    end

  end

  module LeaveConstraints
    require 'leave_constraints'
  
    attr_reader :constraint

    def json()
      throw :constraint_not_set if constraint.nil?
      build_employee_json(base_query.where(constraint.as_constraint_override => true), "#{constraint}")
    end
  
  end

  # exceeds_number_of_days_notice_required: "Exceeds the number of days notice required"
  class LeaveRequestsExceedingDaysNotice < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :exceeds_number_of_days_notice_required
      super
    end

    def self.display_name
      'Leave exceeding required notice period'
    end

  end

  # exceeds_minimum_number_of_days_per_request: "Is less than the minimum allowed number of days per request"
  class LeaveRequestsExceedingMinDays < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :exceeds_minimum_number_of_days_per_request
      super
    end

    def self.display_name
      'Leave exceeding minimum days per request'
    end

  end

  # exceeds_maximum_number_of_days_per_request: "Is greater than the maximum allowed number of days per request"
  class LeaveRequestsExceedingMaxDays < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :exceeds_maximum_number_of_days_per_request
      super
    end

    def self.display_name
      'Leave exceeding maximum days per request'
    end

  end

  # exceeds_leave_cycle_allowance: "Exceeds the maximum allowance for the leave cycle"
  class LeaveRequestsExceedingAllowance < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :exceeds_leave_cycle_allowance
      super
    end

    def self.display_name
      'Leave exceeding cycle allowance'
    end

  end

  # exceeds_negative_leave_balance: "Exceeds the maximum negative balance for the leave cycle"
  class LeaveRequestsExceedingNegativeBalance < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :exceeds_negative_leave_balance
      super
    end

    def self.display_name
      'Leave exceeding permitted negative balance'
    end

  end

  # is_unscheduled: "May be considered as unscheduled leave"
  class UnscheduledLeaveRequests < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :is_unscheduled
      super
    end

    def self.display_name
      'Unscheduled leave'
    end

  end

  # is_adjacent: "Is adjacent to a weekend, public holiday or another leave request"
  class AdjacentLeaveRequests < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :is_adjacent
      super
    end

    def self.display_name
      'Leave adjacent to a weekend, public holiday or other leave'
    end

  end

  # requires_documentation: "Requires supporting documentation"
  class LeaveRequestsRequiringDocumentation < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :requires_documentation
      super
    end

    def self.display_name
      'Leave requiring documentation'
    end

  end

  # overlapping_request: "Overlaps one or more another leave request"
  class OverlappingLeaveRequests < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :overlapping_request
      super
    end

    def self.display_name
      'Leave with overlapping leave'
    end

  end

  # exceeds_maximum_future_date: "Leave request made far in advance"
  class LeaveRequestsExceedingMaxFutureDate < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :exceeds_maximum_future_date
      super
    end

    def self.display_name
      'Leave exceeding max permitted future date'
    end

  end

  # exceeds_maximum_back_date: "Leave request made far in the past"
  class LeaveRequestsExceedingMaxBackDate < Base
    include LeaveConstraints
    
    def initialize(criteria)
      @constraint = :exceeds_maximum_back_date
      super
    end

    def self.display_name
      'Leave exceeding max permitted back date'
    end

  end

  # additional

  class UnscheduledLeaveAdjacent < Base
  
    def self.display_name
      'Unscheduled leave adjacent to a weekend, holiday or other leave'
    end
    
    def json
      build_employee_json(base_query.where(:is_unscheduled.as_constraint_override => true, :is_adjacent.as_constraint_override => true))
    end
  
  end

  class UnscheduledLeaveByDepartment < Base
  
    def self.display_name
      'Unscheduled leave by department'
    end
    
    def json
      json = ""
      
      query = base_query
        .where(:is_unscheduled.as_constraint_override => true)
          .joins(:employee => :department)
      
      query.group(:department_id)
           .count()
           .each do |department_id, count|
        
        department = Department.find(department_id)
        
        # calculate the duration of the leave requests
        department_query = query.where(:employees => {:department_id => department_id})
        duration = department_query.sum(:duration)

        json << data_item(department.to_param, 
                          department.title, 
                          count, 
                          duration, 
                          "#{department.title} (#{count}/#{pluralize(duration, 'day')})") do

          build_employee_json(department_query)
                          
        end
        
      end
      json
    end
  
  end
  
  class UnscheduledLeaveByLocation < Base
  
    def self.display_name
      'Unscheduled leave by location'
    end
    
    def json
      json = ""
      
      query = base_query
        .where(:is_unscheduled.as_constraint_override => true)
          .joins(:employee => :location)
      
      query.group(:location_id)
           .count()
           .each do |location_id, count|
        
        location = Location.find(location_id)
        
        # calculate the duration of the leave requests
        location_query = query.where(:employees => {:location_id => location_id})
        duration = location_query.sum(:duration)

        json << data_item(location.to_param, 
                          location.title, 
                          count, 
                          duration, 
                          "#{location.title} (#{count}/#{pluralize(duration, 'day')})") do

          build_employee_json(location_query)
                          
        end
        
      end
      json
    end
  
  end

##
# TODO: implement once multi-country support has be incorporated
#
#  class UnscheduledLeaveByCountry < Base
#  
#    def self.display_name
#      'Unscheduled leave by country'
#    end
#    
#    def json
#          
#    end
#  
#  end

  private
  
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
