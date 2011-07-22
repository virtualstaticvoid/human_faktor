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
  
  def can_carry_over?
    false
  end
  
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
      start_date += cycle_duration_in_units
    end
    index
  end
  
  def cycle_start_date_for(index)
    self.cycle_start_date + cycle_duration_in_units(index)  
  end

  def cycle_end_date_for(index)
    self.cycle_start_date + cycle_duration_in_units(index + 1) - 1.day
  end
  
  def cycle_start_date_of(date)
    # REFACTOR: better way using a formula?
    leave_cycle_index = self.cycle_index_of(date)
    start_date = self.cycle_start_date
    leave_cycle_index.times do |i|
      start_date += cycle_duration_in_units
    end
    start_date
  end

  def cycle_end_date_of(date)
    # REFACTOR: better way using a formula?
    leave_cycle_index = self.cycle_index_of(date) + 1
    start_date = self.cycle_start_date
    leave_cycle_index.times do |i|
      start_date += cycle_duration_in_units
    end
    start_date - 1.day
  end

  # calculates the total allowance for the leave cycle of the given `date_as_at`
  def allowance_for(employee, date_as_at)
    raise InvalidOperationException if date_as_at < self.cycle_start_date
  
    # for non-accruing leave types, this is simply the configured
    # allowance irrespect of the leave cycle of the given `date_as_at`
    
    #
    # TODO: implement rolling window functionality
    #
    
    employee.leave_cycle_allocation_for(self)

  end

  # calculates the leave take on balance for the leave cycle of the given `date_as_at`
  def leave_take_on_for(employee, date_as_at)
    raise InvalidOperationException if date_as_at < self.cycle_start_date
  
    cycle_start_date = self.cycle_start_date_of(date_as_at)
    cycle_end_date = self.cycle_end_date_of(date_as_at)

    leave_take_on = 0

    # include take on balance if within the given leave cycle
    if !employee.take_on_balance_as_at.nil? && 
          employee.take_on_balance_as_at >= cycle_start_date && 
              employee.take_on_balance_as_at <= cycle_end_date

      leave_take_on += employee.take_on_balance_for(self)
    end

    leave_take_on
  end    

  # calculates the leave taken for the leave cycle of the given `date_as_at`
  def leave_taken_for(employee, date_as_at, unpaid = false)
    raise InvalidOperationException if date_as_at < self.cycle_start_date
  
    start_date = self.cycle_start_date_of(date_as_at)
    end_date = date_as_at # self.cycle_end_date_of(date_as_at)
    
    leave_taken(employee, start_date, end_date, unpaid)
  end
  
  def leave_outstanding_for(employee, date_as_at, unpaid = false)
    raise InvalidOperationException if date_as_at < self.cycle_start_date
  
    start_date = date_as_at # self.cycle_start_date_of(date_as_at)
    end_date = self.cycle_end_date_of(date_as_at)
    
    leave_taken(employee, start_date, end_date, unpaid)
  end

  # supported leave types

  class Annual < LeaveType
  
    default_values :color => '0037C7'
  
    def can_carry_over?
      true
    end
  
    def allowance_for(employee, date_as_at)

      # annual leave is accrued, so the allowance needs to be "pro-rated" up to the given `date_as_at`
      # also, the employees fixed_daily_hours ratio needs to be applied
      # leave carried over (or negative balance) from the previous cycle must be included
      
      # this calculation needs to happen from the start_date of the leave type (i.e. beginning of time)
      
      # NB: unpaid leave affects the calculation!!!
      #  i.e. comes off the allowance

      final_allowance = 0
      index = 0
      to_index = self.cycle_index_of(date_as_at)
      cycle_duration_days = cycle_duration_in_units / 1.days
      
      # get the employee "start date"
      employee_start_date = if employee.take_on_balance_as_at.present?
                              employee.take_on_balance_as_at
                            elsif employee.start_date.present?
                              employee.start_date
                            else
                              self.cycle_start_date
                            end  

      begin
      
        end_date = self.cycle_end_date_for(index)
        
        unless employee_start_date > end_date

          start_date = self.cycle_start_date_for(index)

          # if the employee only started within the cycle...
          #  then the accrual is pro-rated from that start date
          start_date = employee_start_date if employee_start_date > start_date

          # end date should be up to the date_as_at
          end_date = date_as_at if end_date > date_as_at

          # ASSERTIONS
          raise InvalidOperationException unless start_date < end_date
          raise InvalidOperationException if start_date > date_as_at
        
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
    
    # TODO: rolling window support

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
  
  private
  
  def cycle_duration_in_units(multiplier = 1)
    case self.cycle_duration_unit
      when DURATION_UNIT_DAYS then (self.cycle_duration * multiplier).days
      when DURATION_UNIT_MONTHS then (self.cycle_duration * multiplier).months
      when DURATION_UNIT_YEARS then (self.cycle_duration * multiplier).years
    end
  end
  
end

