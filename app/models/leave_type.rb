require 'date'

class LeaveType < ActiveRecord::Base
  include AccountScopedModel
  extend NestedClassesHelper

  # units for cycle duration
  DURATION_UNIT_DAYS = 1
  DURATION_UNIT_MONTHS = 2
  DURATION_UNIT_YEARS = 3
  DURATIONS = [DURATION_UNIT_DAYS, DURATION_UNIT_MONTHS, DURATION_UNIT_YEARS]

  default_values :cycle_duration_unit => DURATION_UNIT_YEARS,
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
  validates :required_days_notice, :numericality => { :greater_than_or_equal_to => 1 }
  validates :max_negative_balance, :numericality => { :greater_than_or_equal_to => 0 }
  
  # display
  validates :color, :hex_color => true
  
  def hex_color
    "##{self.color}"
  end

  def to_s
    self.class.name.gsub(/LeaveType::/, '')
  end
  
  def leave_type_name
    self.class.name.gsub(/LeaveType::/, '').downcase
  end
  
  def cycle_index_of(date)
    # REFACTOR: better way using a formula?
    index, start_date = -1, self.cycle_start_date
    while start_date <= date
      index += 1
      start_date += cycle_duration_hours
    end
    index
  end
  
  def cycle_start_date_of(date)
    # REFACTOR: better way using a formula?
    leave_cycle_index = self.cycle_index_of(date)
    start_date = self.cycle_start_date
    leave_cycle_index.times do |i|
      start_date += cycle_duration_hours
    end
    start_date
  end
  
  # supported leave types

  class Annual < LeaveType
  
    default_values :color => '0037C7'
  
    # TODO: add accrual calculation methods...
    
  end

  class Educational < LeaveType

    default_values :color => '00DF1F'

  end

  class Medical < LeaveType

    default_values :color => '8B7300'

  end

  class Maternity < LeaveType

    default_values :color => 'FF3F3F'

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
  
  private
  
  def cycle_duration_hours
    case self.cycle_duration_unit
      when DURATION_UNIT_DAYS then self.cycle_duration.days
      when DURATION_UNIT_MONTHS then self.cycle_duration.months
      when DURATION_UNIT_YEARS then self.cycle_duration.years
    end
  end
  
end

