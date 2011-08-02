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
    
    def data_item(id, name, area, heat)
      return <<JSON_DATA
{ 'id': '#{id}', 
  'name': '#{name}', 
  'data': { 
    '$area': #{area}, 
    '$color': '#{heat_map_color(heat)}' 
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
      data = ""
      base_query
        .where(:is_unscheduled.as_constraint_override => true)
        .group(:employee_id)
        .count()
        .each do |employee_id, count_of_unscheduled|
        
        employee = Employee.find(employee_id)
        
        duration = base_query.where(:employee_id => employee_id)
                            .sum(:duration)

        data << data_item(employee.to_param, employee.full_name, count_of_unscheduled, duration) do
          build = ""
          base_query.where(:employee_id => employee_id).each do |leave_request|
            build << data_item(leave_request.to_param, leave_request.to_s, leave_request.duration, leave_request.duration)
          end
          build
        end
        
      end
      data
    end
  
  end
  
  class UnscheduledLeaveByDepartment < Base
  
    def self.display_name
      'Unscheduled leave by department'
    end
    
    def json
          
    end
  
  end
  
  class UnscheduledLeaveByLocation < Base
  
    def self.display_name
      'Unscheduled leave by location'
    end
    
    def json
          
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
