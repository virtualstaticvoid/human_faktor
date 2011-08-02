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

  attr_accessor :leave_type_id

  attr_accessor :date_from
  validates :date_from, :timeliness => { :type => :date }
  
  attr_accessor :date_to
  validates :date_to, :timeliness => { :type => :date }
  
  attr_accessor :display_by

  attr_accessor :heat_map
  validates_presence_of :heat_map
  
  def initialize(account, employee)
    @account = account
    @employee = employee
    @date_from = Date.today - 365
    @date_to = Date.today
    @heat_map = LeaveRequestsByEmployee.name
  end
  
  def heat_maps
    Base.heat_maps
  end
  
  def heat_map_type
    constantize(@heat_map)
  end
  
  def json
    self.heat_map_type.new(self).json
  end
  
  class Base
    include ActionView::Helpers::TextHelper
  
    @@heat_maps = []
  
    def self.inherited(klass)
      @@heat_maps << klass
    end
    
    def self.heat_maps
      @@heat_maps
    end
    
    attr_reader :account
    attr_reader :employee

    attr_reader :leave_type_id
    attr_reader :date_from
    attr_reader :date_to
    attr_reader :display_by
    
    def initialize(criteria)
      @account = criteria.account
      @employee = criteria.employee
      @leave_type_id = criteria.leave_type_id
      @date_from = criteria.date_from
      @date_to = criteria.date_to
      @display_by = criteria.display_by  
    end
    
    def json
      throw :not_implemented
    end
    
    protected
    
    def base_query
      query = @account
          .leave_requests
          .active
          .where('date_from BETWEEN :date_from AND :date_to', { :date_from => date_from, :date_to => date_to })
      query = query.where(:leave_type_id => leave_type_id) unless leave_type_id.nil?
      return query
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
      data = ""
      base_query
          .group(:employee)
          .sum(:duration).each do |employee, duration|
          
        data << "{ 'id': '#{employee.to_param}', 'name': '#{employee} (#{pluralize(duration, 'day')})', 'data': { '$area': #{duration}, '$color': '#{heat_map_color(duration)}' } },"
      end
      data
    end

  end

  class LeaveRequestsByDuration < Base

    def self.display_name
      'Leave requests by duration'
    end

    def json
      data = ""
      base_query
          .group(:duration)
          .count().each do |no_days, count|
            
        data << "{"
        data << " 'id': '_#{no_days}', 'name': '#{pluralize(no_days, 'day')} (#{count})', 'data': { '$area': #{count}, '$color': '#{heat_map_color(count)}' },"
        data << " 'children': ["
        
        @account.leave_requests.active
            .where(:duration => no_days).each do |leave_request|
          data << "{ 'id': '_#{leave_request.to_param}', 'name': '#{leave_request.to_s}', 'data': { '$area': #{leave_request.duration}, '$color': '#{heat_map_color(leave_request.duration)}' } },"
        end
        
        data << " ] "
        data << "},"
        
      end
      data
    end

  end
  
  class LeaveRequestsUnpaid < Base

    def self.display_name
      'Unpaid leave requests'
    end

    def json
      data = ""
      base_query
          .where(:unpaid => true)
          .group(:employee_id)
          .count().each do |employee_id, count|
            
        employee = Employee.find(employee_id)

        data << "{ 'id': '#{employee.to_param}', 'name': '#{employee} (#{count})', 'data': { '$area': #{count}, '$color': '#{heat_map_color(count)}' } },"
      end
      data
    end

  end

  module LeaveConstraints
    require 'leave_constraints'
  
    attr_reader :constraint

    def json()
      throw :constraint_not_set if constraint.nil?
      
      data = ""
      base_query
          .where(constraint.as_constraint_override => true)
          .group(:employee_id)
          .count().each do |employee_id, count|
        
        employee = Employee.find(employee_id)
        
        data << "{"
        data << " 'id': '#{employee.to_param}', 'name': '#{employee} (#{count})', 'data': { '$area': #{count}, '$color': '#{heat_map_color(count)}' }, "
        data << " 'children': ["
        
        @account.leave_requests.active
            .where(:employee_id => employee_id)
            .where(constraint.as_constraint_override => true).each do |leave_request|
          data << "{ 'id': '_#{leave_request.to_param}', 'name': '#{leave_request.to_s}', 'data': { '$area': #{leave_request.duration}, '$color': '#{heat_map_color(leave_request.duration)}' } },"
        end
        
        data << " ] "
        data << "},"

      end
      data
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
      'Leave adjacent to a weekend or public holiday'
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
