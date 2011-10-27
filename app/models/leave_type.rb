require 'date'
require 'action_view/helpers/text_helper'

class LeaveType < ActiveRecord::Base
  include AccountScopedModel
  extend NestedClassesHelper
  include ActionView::Helpers::TextHelper
  
  #
  # NNB: assumes that the cycle_start_date is less than any employee start or take on date!
  #
  
  default_scope order(:display_order)

  # units for cycle duration
  DURATION_UNIT_DAYS = 1
  DURATION_UNIT_MONTHS = 2
  DURATION_UNIT_YEARS = 3
  DURATIONS = [DURATION_UNIT_DAYS, DURATION_UNIT_MONTHS, DURATION_UNIT_YEARS]

  default_values :cycle_start_date => Date.new(Date.today.year, 1, 1),
                 :cycle_duration => 1,
                 :cycle_duration_unit => DURATION_UNIT_YEARS,
                 :cycle_days_carry_over => 0,
                 :employee_capture_allowed => true,
                 :approver_capture_allowed => true,
                 :admin_capture_allowed => true,
                 :approval_required => true,
                 :requires_documentation => false,
                 :requires_documentation_after => 1,
                 :unscheduled_leave_allowed => true,
                 :max_days_for_future_dated => 365,
                 :max_days_for_back_dated => 365,
                 :min_days_per_single_request => 0.5,
                 :max_days_per_single_request => 30,
                 :required_days_notice => 1,
                 :max_negative_balance => 0

  # maps to derived class of LeaveType::Base
  validates :type, :uniqueness => { :scope => [ :account_id ] }

  # leave cycle information
  validates :cycle_start_date, :timeliness => { :type => :date}
  validates :cycle_duration, :numericality => { :greater_than => 0 }
  validates :cycle_duration_unit, :inclusion => { :in => DURATIONS }
  validates :cycle_days_allowance, :numericality => { :greater_than => 0 }
  validates :cycle_days_carry_over, :numericality => { :greater_than_or_equal_to => 0 }

  # default to false for all leave types (except Annual - below)
  def has_absolute_start_date?
    false
  end
  
  # default to false for all leave types (except Annual - below)
  def can_carry_over?
    false
  end
  
  # default to true for all leave types
  def can_take_on?
    true
  end
  
  # default to any gender all all leave types (except Maternity - below)
  def gender_filter
    Employee::GENDERS
  end

  # capture permissions
  validates :employee_capture_allowed, :inclusion => { :in => [true, false] }
  validates :approver_capture_allowed, :inclusion => { :in => [true, false] }
  validates :admin_capture_allowed, :inclusion => { :in => [true, false] }

  # approval permissions
  validates :approval_required, :inclusion => { :in => [true, false] }

  # constraints
  validates :requires_documentation, :inclusion => { :in => [true, false] }
  validates :requires_documentation_after, :numericality => { :greater_than_or_equal_to => 1 }
  validates :unscheduled_leave_allowed, :inclusion => { :in => [true, false] }
  validates :max_days_for_future_dated, :numericality => { :greater_than_or_equal_to => 1 }
  validates :max_days_for_back_dated, :numericality => { :greater_than_or_equal_to => 1 }
  validates :min_days_per_single_request, :numericality => { :greater_than_or_equal_to => 0 }
  validates :max_days_per_single_request, :numericality => { :greater_than_or_equal_to => 1 }
  validates :required_days_notice, :numericality => { :greater_than_or_equal_to => 0 }
  validates :max_negative_balance, :numericality => { :greater_than_or_equal_to => 0 }
  
  # display
  validates :color, :hex_color => true
  
  def hex_color
    "##{self.color}"
  end

  def to_s
    self.class.name.gsub(/LeaveType::/, '')
  end
  
  def duration_display
    case self.cycle_duration_unit
      when DURATION_UNIT_DAYS then pluralize(self.cycle_duration, 'day')
      when DURATION_UNIT_MONTHS then pluralize(self.cycle_duration, 'month')
      when DURATION_UNIT_YEARS then pluralize(self.cycle_duration, 'year')
    end
  end
  
  def leave_type_name
    self.class.name.gsub(/LeaveType::/, '').downcase
  end

  def employee_start_date(employee)
    return nil unless employee

    # try using the employees start date
    employee.start_date.present? ?
      employee.start_date :
      employee.created_at.to_date      # use the date the record was created...

  end

  #
  # determines the cycle index for the given date
  #
  #  i.e. starting from the employees employment start date (or leave balance take on date)
  #       increments for each successive cycle by the cycle_duration.
  #
  #  e.g. a date which falls in the second cycle will yield an index of 1 (NOTE: zero based!)
  #
  # returns nil if the date is prior to the employees start date
  #
  def cycle_index_of(employee, date)
    return nil unless employee && date

    index, start_date = -1, employee_start_date(employee)
    return nil if date < start_date

    while start_date <= date
      index += 1
      start_date += cycle_duration_in_units
    end
    index
  end
  
  # determines the start date for the given cycle index
  def cycle_start_date_for(employee, index)
    return nil unless employee
    
    index < 0 ?
      nil :
      employee_start_date(employee) + cycle_duration_in_units(index)
  end

  # determines the end date for the given cycle index
  def cycle_end_date_for(employee, index)
    return nil unless employee

    index < 0 ?
      nil :
      employee_start_date(employee) + cycle_duration_in_units(index + 1) - 1.day
  end
    
  # given an arbitrary date, get the start date of the cycle in which it falls
  def cycle_start_date_of(employee, date)
    return nil unless employee && date

    index = self.cycle_index_of(employee, date)
    return nil unless index
    
    self.cycle_start_date_for(employee, index)
  end

  # given an arbitrary date, get the end date of the cycle in which it falls
  def cycle_end_date_of(employee, date)
    return nil unless employee && date

    index = self.cycle_index_of(employee, date)
    return nil unless index
    
    self.cycle_start_date_for(employee, index + 1) - 1.day
  end

  # calculates the total allowance for the leave cycle of the given `date_as_at`
  def allowance_for(employee, date_as_at)
    return nil unless employee && date_as_at
  
    # if the date_as_at is prior to the start date, then return zero!
    return 0 if date_as_at <= employee_start_date(employee)
    return 0 if employee.take_on_balance_as_at.present? && date_as_at <= employee.take_on_balance_as_at
    
    # for non-accruing leave types, this is simply the configured
    # allowance irrespective of the leave cycle of the given `date_as_at`
    # unless there is a take on balance

    take_on_balance = self.leave_take_on_for(employee, date_as_at)

    # NOTE: Employee#leave_cycle_allocation_for reverts to leave_type.cycle_days_allowance
    #  unless the employee has an override for the allocation
    take_on_balance > 0 ? 
      0 : 
      employee.leave_cycle_allocation_for(self)

  end

  # calculates the leave take on balance for the leave cycle of the given `date_as_at`
  def leave_take_on_for(employee, date_as_at)
    return nil unless employee && date_as_at
  
    cycle_start_date = self.cycle_start_date_of(employee, date_as_at)
    cycle_end_date = self.cycle_end_date_of(employee, date_as_at)

    # include take on balance if within the given leave cycle
    if self.can_take_on? &&
         !employee.take_on_balance_as_at.nil? && 
            employee.take_on_balance_as_at >= cycle_start_date && 
                employee.take_on_balance_as_at <= cycle_end_date

      employee.take_on_balance_for(self)
    else
      0
    end
  end    

  # calculates the leave taken for the leave cycle of the given `date_as_at`
  def leave_taken_for(employee, date_as_at, unpaid = false)
    return nil unless employee && date_as_at
    return nil if date_as_at < employee_start_date(employee)
  
    start_date = self.cycle_start_date_of(employee, date_as_at)
    end_date = date_as_at - 1.day
    
    leave_taken(employee, start_date, end_date, unpaid)
  end
  
  def leave_outstanding_for(employee, date_as_at, unpaid = false)
    return nil unless employee && date_as_at
    return nil if date_as_at < employee_start_date(employee)
  
    start_date = date_as_at
    end_date = self.cycle_end_date_of(employee, date_as_at)
    
    leave_taken(employee, start_date, end_date, unpaid)
  end

  # supported leave types

  class Annual < LeaveType
  
    default_values :color => '0037C7'
  
    def has_absolute_start_date?
      true
    end

    #
    # determines the cycle index for the given date
    #
    # annual leave period end dates are fixed, unlike the other types which roll on from the
    # employee start date (or leave balance take on date)
    #
    # the first cycle starts from the employees start date and ends on the fixed end date
    # according to the leave cycle start date and duration
    #
    # returns nil if the date is prior to the cycle or employee start date
    #
    def cycle_index_of(employee, date)
      return nil unless employee && date

      index, start_date, employee_start_date = -1, self.cycle_start_date, employee_start_date(employee)
      return nil if date < start_date || date < employee_start_date

      while start_date <= date
        start_date += cycle_duration_in_units
        index += 1 if start_date >= employee_start_date
      end
      index
    end

    # determines the start date for the given cycle index
    def cycle_start_date_for(employee, index)
      return nil unless employee
      return nil if index < 0
      return employee_start_date(employee) if index == 0

      start_date, employee_start_date = self.cycle_start_date, employee_start_date(employee)

      while index > 0
        start_date += cycle_duration_in_units
        index -= 1 if start_date >= employee_start_date
      end
      start_date
    end

    # determines the end date for the given cycle index
    def cycle_end_date_for(employee, index)
      return nil unless employee
      return nil if index < 0

      cycle_start_date_for(employee, index + 1) - 1.day
    end
      
    # given an arbitrary date, get the start date of the cycle in which it falls
    # def cycle_start_date_of(employee, date)
    # end

    # given an arbitrary date, get the end date of the cycle in which it falls
    # def cycle_end_date_of(employee, date)
    # end

    def can_carry_over?
      true
    end
  
    def allowance_for(employee, date_as_at)
  
      # if the date_as_at is prior to the start date, then return zero!
      employee_start_date = employee_start_date(employee)  
  
      return 0 if date_as_at <= employee_start_date
      return 0 if employee.take_on_balance_as_at.present? && date_as_at <= employee.take_on_balance_as_at

      # annual leave is accrued, so the allowance needs to be "pro-rated" up to the given `date_as_at`
      # also, the employees fixed_daily_hours ratio needs to be applied
      # leave carried over (or negative balance) from the previous cycle must be included
      
      # this calculation needs to happen from the start_date of the leave type (i.e. beginning of time)
      
      # NB: unpaid leave affects the calculation!!!
      #  i.e. comes off the allowance

      final_allowance = 0
      index = 0
      to_index = self.cycle_index_of(employee, date_as_at)
      cycle_duration_days = cycle_duration_in_units / 1.days
      
      begin
      
        end_date = self.cycle_end_date_for(employee, index)
        
        # only include cycles from when the employee was employed
        if employee_start_date < end_date

          start_date = self.cycle_start_date_for(employee, index)

          # adjust the start date if the employee started after the cycle start date.
          #  the accrual will therefore be pro-rated
          start_date = employee_start_date if employee_start_date >= start_date

          # end date should be up to the date_as_at
          end_date = date_as_at if date_as_at >= start_date && date_as_at < end_date

          # ASSERTIONS
          raise InvalidOperationException if start_date > end_date
        
          days_in_cycle = end_date - start_date
          
          # NOTE: includes all leave up to the end of the cycle
          leave_taken = leave_taken(employee, start_date, end_date, false)
          unpaid_leave_taken = leave_taken(employee, start_date, end_date, true)

          # the allowance is pro-rated 
          allowance = (self.cycle_days_allowance / (cycle_duration_days - unpaid_leave_taken)) * days_in_cycle

          final_allowance += allowance
          
        end
        
        index += 1

      end while index <= to_index

      final_allowance.round(1)  # NB: round up to 1 decimal
      
    end
    
  end

  class Educational < LeaveType

    default_values :color => '00DF1F'

  end

  class Medical < LeaveType

    default_values :color => '8B7300'
    
  end

  class Maternity < LeaveType

    default_values :color => 'FF3F3F'

    def gender_filter
      [Employee::GENDER_FEMALE]
    end

  end

  class Compassionate < LeaveType

    default_values :color => 'FFBFBF'

  end

  # define helper methods for each type
  # e.g. provides access via @account.leave_types.annual
  nested_classes.each do |klass|
    next unless klass.parent == LeaveType
    define_singleton_method klass.name.gsub(/LeaveType::/, '').downcase do
      LeaveType.where(:type => klass.name).first
    end
  end
  
  def self.type_from(symbol)
    raise ArgumentError, 'expected symbol' unless symbol.is_a?(Symbol)
    "LeaveType::#{symbol.to_s.capitalize}".constantize
  end
  
  # helpers
  def self.for_each_leave_type(&block)
    nested_classes.each do |klass|
      next unless klass.parent == LeaveType
      block.call(klass)
    end  
  end

  def self.for_each_leave_type_name(&block)
    nested_classes.each do |klass|
      next unless klass.parent == LeaveType
      leave_type_name = klass.name.gsub(/LeaveType::/, '').downcase
      block.call(leave_type_name)
    end  
  end
  
  protected
  
  def leave_taken(employee, start_date, end_date, unpaid = false)
    employee.leave_requests.active.where(
      :leave_type_id => self.id,
      :unpaid => unpaid
    ).where(
      ' date_from BETWEEN :from AND :to ',
      { :from => start_date, :to => end_date }
    ).sum(:duration)
  end
  
  def cycle_duration_in_units(multiplier = 1)
    case self.cycle_duration_unit
      when DURATION_UNIT_DAYS then (self.cycle_duration * multiplier).days
      when DURATION_UNIT_MONTHS then (self.cycle_duration * multiplier).months
      when DURATION_UNIT_YEARS then (self.cycle_duration * multiplier).years
    end
  end
  
end
