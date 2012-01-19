require 'date'
require 'action_view/helpers/text_helper'

class LeaveType < ActiveRecord::Base
  include AccountScopedModel
  extend NestedClassesHelper
  include ActionView::Helpers::TextHelper
  
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

  # maps to derived classes of LeaveType (handled by ActiveRecord)
  validates :type, :uniqueness => { :scope => [ :account_id ] }

  def leave_type_name
    self.class.name.gsub(/LeaveType::/, '').downcase
  end

  # leave cycle information
  validates :cycle_start_date, :timeliness => { :type => :date }    # only applicable for accruing types

  validates :cycle_duration, :numericality => { :greater_than => 0 }
  validates :cycle_duration_unit, :inclusion => { :in => DURATIONS }

  def cycle_duration_in_units
    case self.cycle_duration_unit
      when DURATION_UNIT_DAYS then self.cycle_duration.days
      when DURATION_UNIT_MONTHS then self.cycle_duration.months
      when DURATION_UNIT_YEARS then self.cycle_duration.years
    end
  end

  def cycle_duration_days
    self.cycle_duration_in_units / 1.day
  end
  
  def duration_display
    case self.cycle_duration_unit
      when DURATION_UNIT_DAYS then pluralize(self.cycle_duration, 'day')
      when DURATION_UNIT_MONTHS then pluralize(self.cycle_duration, 'month')
      when DURATION_UNIT_YEARS then pluralize(self.cycle_duration, 'year')
    end
  end
    
  validates :cycle_days_allowance, :numericality => { :greater_than => 0 }
  validates :cycle_days_carry_over, :numericality => { :greater_than_or_equal_to => 0 }

  # TODO: need a better name for this property/behaviour
  # ... rolling window... fixed aniversary date...
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
  
  def cycle_start_date_for(date_as_at, employee)

    # for NON-ACCRUING leave types
    # the start date co-incides with the employees start date
    # and each aniversary is an increment of the cycle duration

    start_date = employee.take_on_balance_as_at.present? ?
      employee.take_on_balance_as_at :
      employee.start_date

    return nil if date_as_at < start_date

    while date_as_at >= (start_date + cycle_duration_days)
      start_date += cycle_duration_days
    end

    start_date
  end

  def cycle_end_date_for(date_as_at, employee)

    # for non-accruing leave types
    # the start date co-incides with the employees start date
    # and each aniversary is an increment of the cycle duration

    start_date = self.cycle_start_date_for(date_as_at, employee)

    (Date.leap?(start_date.year) ?
      start_date + cycle_duration_days :
      start_date + cycle_duration_days - 1.day) if start_date

  end

  def leave_carried_forward_for(employee, date_as_at)
    # accumulate leave from the previous period(s) up to the `date_as_at`
    0
  end

  # calculates the total allowance for the leave cycle of the given `date_as_at`
  # there is no carried forward balance for non-accrued leave types... only take on balances...
  def allowance_for(employee, date_as_at)
    raise ArgumentError unless employee && date_as_at
  
    # if the date_as_at is prior to the start date, then return zero!
    return 0 if date_as_at < employee.start_date
    return 0 if employee.take_on_balance_as_at.present? && date_as_at < employee.take_on_balance_as_at
    return 0 if self.take_on_balance_for(employee, date_as_at) > 0

    # for NON-ACCRUING leave types, this is simply the configured
    # allowance irrespective of the leave cycle of the given `date_as_at`
    # unless there is a take on balance

    # NOTE: Employee#leave_cycle_allocation_for reverts to leave_type.cycle_days_allowance
    #  unless the employee has an override for the allocation

    employee.leave_cycle_allocation_for(self)

  end

  # calculates the leave take on balance for the leave cycle of the given `date_as_at`
  def take_on_balance_for(employee, date_as_at)
    raise ArgumentError unless employee && date_as_at

    # need to have a `take_on_balance_as_at` date
    return 0 if employee.take_on_balance_as_at.nil?
    return 0 if date_as_at < employee.take_on_balance_as_at
  
    cycle_start_date = self.cycle_start_date_for(date_as_at, employee)
    cycle_end_date = self.cycle_end_date_for(date_as_at, employee)

    # include take on balance if within the given leave cycle
    if self.can_take_on? &&
        employee.take_on_balance_as_at >= cycle_start_date &&
          employee.take_on_balance_as_at <= cycle_end_date
      employee.take_on_balance_for(self)
    else
      0
    end
  end    

  # calculates the leave taken for the leave cycle of the given `date_as_at`
  def leave_taken_for(employee, date_as_at, unpaid = false)
    raise ArgumentError unless employee && date_as_at

    return 0 if date_as_at < employee.start_date
  
    start_date = self.cycle_start_date_for(date_as_at, employee)
    end_date = date_as_at
    
    leave_taken(employee, start_date, end_date, unpaid)
  end
  
  def leave_outstanding_for(employee, date_as_at, unpaid = false)
    raise ArgumentError unless employee && date_as_at

    return 0 if date_as_at < employee.start_date
  
    start_date = date_as_at + 1.day
    end_date = self.cycle_end_date_for(date_as_at, employee)
    
    leave_taken(employee, start_date, end_date, unpaid)
  end

  # supported leave types

  class Annual < LeaveType
  
    default_values :color => '0037C7'
  
    # TODO: need a better name for this property/behaviour
    # ... rolling window... fixed anniversary date...
    def has_absolute_start_date?
      true
    end

    def can_carry_over?
      true
    end

    def cycle_start_date_for(date_as_at, employee)
      raise ArgumentError unless employee && date_as_at

      return nil if employee.start_date > date_as_at
      return nil if employee.take_on_balance_as_at.present? && employee.take_on_balance_as_at > date_as_at

      # for ACCRUING leave types
      # cycle start date is the employee start date
      # if the date is within the first cycle
      # there after, it is the date in respect of the 
      # cycle start date, except for the year of the date as at.

      start_date = Date.new(
        date_as_at.year, 
        self.cycle_start_date.month, 
        self.cycle_start_date.day
      )

      start_date = Date.new(
        date_as_at.year - 1, 
        self.cycle_start_date.month, 
        self.cycle_start_date.day
      ) if start_date > date_as_at

      employee_start_date = employee.take_on_balance_as_at.present? ?
        employee.take_on_balance_as_at :
        employee.start_date

      (employee_start_date > start_date) && (employee_start_date < (start_date + cycle_duration_days)) ?
        employee_start_date :
        start_date 

    end

    def cycle_end_date_for(date_as_at, employee)
      raise ArgumentError unless employee && date_as_at

      return nil if employee.start_date > date_as_at
      return nil if employee.take_on_balance_as_at.present? && employee.take_on_balance_as_at > date_as_at

      start_date = Date.new(
        date_as_at.year, 
        self.cycle_start_date.month, 
        self.cycle_start_date.day
      )
      
      start_date = Date.new(
        date_as_at.year - 1, 
        self.cycle_start_date.month, 
        self.cycle_start_date.day
      ) if start_date > date_as_at

      Date.leap?(start_date.year) ?
        start_date + cycle_duration_days :
        start_date + cycle_duration_days - 1.day

    end
  
    def leave_carried_forward_for(employee, date_as_at)
      raise ArgumentError unless employee && date_as_at

      # accumulate leave from the start date up to the cycle start date of `date_as_at`
      cycle_start_date = self.cycle_start_date_for(date_as_at, employee)
      return 0 unless cycle_start_date

      up_to_date = cycle_start_date - 1.day

      start_date = employee.take_on_balance_as_at.present? ?
          employee.take_on_balance_as_at :
          employee.start_date

      return 0 if start_date > up_to_date

      leave_allowance = employee.take_on_balance_as_at.present? ?
          employee.take_on_balance_for(self) :
          0.0

      while start_date < up_to_date

        end_date = self.cycle_end_date_for(start_date, employee)

        days_in_cycle = end_date - start_date

        # subtract the leave taken in this period
        leave_taken = leave_taken(employee, start_date, end_date, false)

        unpaid_leave_taken = leave_taken(employee, start_date, end_date, true)

        # NOTE: allowance is pro-rated
        leave_allowance += ((self.cycle_days_allowance / (cycle_duration_days - unpaid_leave_taken)) * days_in_cycle) - leave_taken

        start_date = end_date + 1.day

      end

      leave_allowance
    end

    def allowance_for(employee, date_as_at)
      raise ArgumentError unless employee && date_as_at

      return 0 if employee.start_date > date_as_at
      return 0 if employee.take_on_balance_as_at.present? && date_as_at < employee.take_on_balance_as_at

      # accumulate leave from the current period start date to the `date_as_at`
      # NOTE: no deductions are made!

      start_date = self.cycle_start_date_for(date_as_at, employee)
      return 0 unless start_date

      end_date = date_as_at
      days_in_cycle = end_date - start_date

      # NOTE: allowance is pro-rated if the employee started intra cycle
      unpaid_leave_taken = leave_taken(employee, start_date, end_date, true)

      ((self.cycle_days_allowance / (cycle_duration_days - unpaid_leave_taken)) * days_in_cycle)

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

    employee.active_leave_request_days.where(
      :leave_requests => {
        :leave_type_id => self.id,
        :unpaid => unpaid
      }
    ).where(
      ' leave_date BETWEEN :date_from AND :date_to ',
      { :date_from => start_date, :date_to => end_date }
    ).sum(:duration)

  end
  
end
