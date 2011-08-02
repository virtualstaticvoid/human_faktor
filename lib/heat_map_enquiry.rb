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

  attr_accessor :heat_map
  validates_presence_of :heat_map
  
  attr_accessor :date_from
  validates :date_from, :timeliness => { :type => :date }
  
  attr_accessor :date_to
  validates :date_to, :timeliness => { :type => :date }
  
  def initialize(account, employee)
    @account = account
    @employee = employee
    @heat_map = UnscheduledLeave.name
    @date_from = Date.today - 365
    @date_to = Date.today
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
  'data': { 
    '$area': #{area}, 
    '$color': '#{heat_map_color(heat)}',
    'title': '#{title}' 
  }, 
  'children': [#{yield if block_given?}] 
},

JSON_DATA
                
    end
  
    def heat_map_color(value)
      HeatMapColorSupport.color_for(value).to_s
    end
    
  end
  
  class UnscheduledLeave < Base
  
    def self.display_name
      'Unscheduled leave'
    end
    
    def json
      build_for_employees(base_query.where(:is_unscheduled.as_constraint_override => true))
    end
    
    def build_for_employees(query)
      json = ""
      query.group(:employee_id)
           .count()
           .each do |employee_id, count_of_unscheduled|
        
        employee = Employee.find(employee_id)
        
        # calculate the duration of the leave requests
        duration = query.where(:employee_id => employee_id).sum(:duration)

        json << data_item(employee.to_param, 
                          employee.full_name, 
                          count_of_unscheduled, 
                          duration, 
                          "#{employee.full_name} (#{count_of_unscheduled}/#{pluralize(duration, 'day')})") do
        
          build_for_leave_requests(query.where(:employee_id => employee_id))
        
        end
        
      end
      json
    end
  
    def build_for_leave_requests(query)
      json = ""
      query.each do |leave_request|
        json << data_item(leave_request.to_param, 
                          leave_request.to_s, 
                          leave_request.duration, 
                          leave_request.duration, 
                          "#{leave_request.leave_type} - #{leave_request.status_text} (#{pluralize(leave_request.duration, 'day')})")
      end
      json
    end
    
  end
  
  class UnscheduledLeaveAdjacent < UnscheduledLeave
  
    def self.display_name
      'Unscheduled leave adjacent to a weekend, holiday or other leave'
    end
    
    def json
      build_for_employees(base_query.where(:is_unscheduled.as_constraint_override => true, :is_adjacent.as_constraint_override => true))
    end
  
  end

  class UnscheduledLeaveByDepartment < UnscheduledLeave
  
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
           .each do |department_id, count_of_unscheduled|
        
        department = Department.find(department_id)
        
        # calculate the duration of the leave requests
        department_query = query.where(:employees => {:department_id => department_id})
        duration = department_query.sum(:duration)

        json << data_item(department.to_param, 
                          department.title, 
                          count_of_unscheduled, 
                          duration, 
                          "#{department.title} (#{count_of_unscheduled}/#{pluralize(duration, 'day')})") do

          build_for_employees(department_query)
                          
        end
        
      end
      json
    end
  
  end
  
  class UnscheduledLeaveByLocation < UnscheduledLeave
  
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
           .each do |location_id, count_of_unscheduled|
        
        location = Location.find(location_id)
        
        # calculate the duration of the leave requests
        location_query = query.where(:employees => {:location_id => location_id})
        duration = location_query.sum(:duration)

        json << data_item(location.to_param, 
                          location.title, 
                          count_of_unscheduled, 
                          duration, 
                          "#{location.title} (#{count_of_unscheduled}/#{pluralize(duration, 'day')})") do

          build_for_employees(location_query)
                          
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
