require 'date'
require 'paper_clip_interpolations'

class LeaveRequest < ActiveRecord::Base
  include AccountScopedModel

  # status values
  STATUS_NEW = 1
  STATUS_PENDING = 2
  STATUS_APPROVED = 3
  STATUS_DECLINED = 4
  STATUS_CANCELLED = 5
  STATUS_REINSTATED = 6
  STATUSES = [STATUS_NEW, STATUS_PENDING, STATUS_APPROVED, STATUS_DECLINED, STATUS_CANCELLED, STATUS_REINSTATED]
  ACTIVE_STATUSES = [STATUS_PENDING, STATUS_APPROVED, STATUS_REINSTATED]

  @@statuses = []
  @@status_names = {}

  LeaveRequest.constants.each do |constant|
    next unless constant =~ /^STATUS_/
    
    constant_value = LeaveRequest.const_get(constant)
    @@statuses << constant_value
    @@status_names[constant_value] = constant.to_s.gsub(/STATUS_/, '').capitalize
    
    define_method "#{constant.downcase}?" do
      self.status == constant_value
    end
    
  end
  
  scope :pending, where(:status => STATUS_PENDING)
  scope :active, where(:status => ACTIVE_STATUSES)

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :status => STATUS_NEW,
                 :half_day_from => false,
                 :half_day_to => false,
                 :unpaid => false,
                 :captured => false

  # constraint field default values
  LeaveConstraints::Base.constraint_names.each do |constraint_name|
    default_value_for constraint_name.as_constraint, false
    default_value_for constraint_name.as_constraint_override, false
  end

  belongs_to :employee
  belongs_to :leave_type
  belongs_to :captured_by, :class_name => 'Employee'
  belongs_to :approver, :class_name => 'Employee'
  belongs_to :approved_declined_by, :class_name => 'Employee'
  belongs_to :cancelled_by, :class_name => 'Employee'
  belongs_to :reinstated_by, :class_name => 'Employee'

  validates :identifier, :presence => true, :uniqueness => true

  validates :employee, :existence => true
  validates :leave_type, :existence => true

  validates :status, 
            :presence => true, 
            :numericality => { :only_integer => true, :in => @@statuses }

  def status_text
    @@status_names[self.status]
  end                                                          

  validates :approver, :existence => true
  
  validates :date_from, :timeliness => { :type => :date }, :allow_nil => false
  validates :half_day_from, :inclusion => { :in => [true, false] }
  
  def date_from_s
    self.date_from.strftime("%Y-%m-%d") + (self.half_day_from ? ' (Half day)' : '')
  end

  validates :date_to, :timeliness => { :type => :date }, :allow_nil => false
  validates :half_day_to, :inclusion => { :in => [true, false] }
  
  def date_to_s
    self.date_to.strftime("%Y-%m-%d") + (self.half_day_to ? ' (Half day)' : '')
  end

  validate :date_from_must_occur_before_date_to, 
           :date_to_must_occur_after_date_from,
           :same_date_half_day

  validates :unpaid, :inclusion => { :in => [true, false] }
  
  def unpaid?
    self.unpaid
  end
  
  # excuse document
  # NOTE: uses the ":account" and ":employee" interpolations
  has_attached_file :document, 
                    :path => "accounts/:account/employees/:employee/leave_requests/:id/:filename",
                    :storage => :s3,
                    :bucket => AppConfig.s3_bucket,
                    :s3_credentials => {
                      :access_key_id => AppConfig.s3_key,
                      :secret_access_key => AppConfig.s3_secret
                    }
                    
  def document_attached?
    # correct method for determining whether there is an attached file?
    self.document.file?
  end                    

  validates :captured_by, :existence => true, :allow_nil => true
  validates :captured, :inclusion => { :in => [true, false] }
  
  def captured?
    self.captured
  end

  def created_at_s
    self.created_at.strftime("%Y-%m-%d")
  end

  validates :approved_declined_by, :existence => true, :allow_nil => true
  validates :approved_declined_at, :timeliness => { :type => :date }, :allow_nil => true

  def approved_declined_at_s
    self.approved_declined_at.strftime("%Y-%m-%d")
  end

  validates :cancelled_by, :existence => true, :allow_nil => true
  validates :cancelled_at, :timeliness => { :type => :date }, :allow_nil => true
  
  def cancelled_at_s
    self.cancelled_at.strftime("%Y-%m-%d")
  end

  validates :reinstated_by, :existence => true, :allow_nil => true
  validates :reinstated_at, :timeliness => { :type => :date }, :allow_nil => true
  
  def reinstated_at_s
    self.reinstated_at.strftime('%Y-%m-%d')
  end

  # description for calendar tooltips
  def description
    "#{self.leave_type} - #{self.employee.full_name} - #{self.status_text}"
  end
  
  validates :duration, :numericality => { :greater_than_or_equal => 0 }
  
  def duration
    read_attribute(:duration) || 0
  end
  
  #
  # Constraints
  #
  def has_constraint_violations?
    LeaveConstraints::Base.constraint_names.each do |constraint_name|
      return true if self.send(constraint_name.as_constraint_override) == true
    end
    false
  end

  # use the identifier for security
  #  users can't guess the number now :-)
  def to_param
    self.identifier
  end
  
  #
  # Actions
  #
  
  def request
    write_attribute :captured, false
    write_attribute :duration, calculate_duration
    evaluate_constraints
    confirm unless !self.valid? || self.has_constraint_violations?
  end
  
  def capture(approver)
    raise InvalidOperationException if approver.nil?

    write_attribute :captured_by_id, approver.id
    write_attribute :captured, true
    write_attribute :duration, calculate_duration
    evaluate_constraints
    unless !self.valid? || self.has_constraint_violations?
      confirm(approver)
    end
  end

  def confirm(employee = nil)
    raise InvalidOperationException unless self.status_new?
    
    write_attribute :status, STATUS_PENDING
    approve(employee, '') if !employee.nil? && self.valid? && self.captured? && self.approver == employee
  end
  
  def approve(approver, comment)
    raise InvalidOperationException if approver.nil?
    raise InvalidOperationException unless self.status_pending?
    raise PermissionDeniedException unless self.can_authorise?(approver)

    write_attribute :approved_declined_by_id, approver.id
    write_attribute :approved_declined_at, Time.now
    write_attribute :approver_comment, comment
    write_attribute :status, STATUS_APPROVED
  end
  
  def decline(approver, comment)
    raise InvalidOperationException if approver.nil?
    raise InvalidOperationException unless self.status_pending?
    raise PermissionDeniedException unless self.can_authorise?(approver)

    write_attribute :approved_declined_by_id, approver.id
    write_attribute :approved_declined_at, Time.now
    write_attribute :approver_comment, comment
    write_attribute :status, STATUS_DECLINED
  end
  
  def cancel(approver)
    raise InvalidOperationException if approver.nil?
    raise PermissionDeniedException unless self.can_cancel?(approver)

    if self.status_new?
      self.destroy
    else
      write_attribute :cancelled_by_id, approver.id
      write_attribute :cancelled_at, Time.now
      write_attribute :status, STATUS_CANCELLED
    end
  end
  
  def reinstate(approver)
    raise InvalidOperationException if approver.nil?
    raise InvalidOperationException unless self.status_cancelled?
    raise PermissionDeniedException unless self.can_authorise?(approver)

    # NB: clear the cancellation details
    write_attribute :cancelled_by_id, nil
    write_attribute :cancelled_at, nil
    
    write_attribute :reinstated_by_id, approver.id
    write_attribute :reinstated_at, Time.now
    write_attribute :status, STATUS_REINSTATED
  end
  
  # helpers
  [:request, :capture, :confirm, :approve, :decline, :reinstate].each do |method|
    define_method "#{method}!" do |*args|
      self.send(method, *args)
      save
    end
  end
  
  def cancel!(approver)
    raise InvalidOperationException if approver.nil?
    self.cancel(approver)
    if self.status_new?
      true
    else
      save unless self.status_new?
    end
  end

  # permissions
  
  #  + approve, decline, reinstate
  def can_authorise?(employee)
    raise InvalidOperationException if employee.nil?
    
    employee.can_authorise_leave? && 
      (self.approver == employee || employee.is_manager_of?(self.employee))
  end

  def can_cancel?(employee)
    raise InvalidOperationException if employee.nil?
    
    self.employee == employee || employee.is_manager_of?(self.employee)
  end

  def calculate_duration
  
    # subtract weekends and holidays!
    weekend_days = (self.date_from..self.date_to).select {|d| [6, 0].include?(d.wday) }.count
    
    holidays = self.account.country.calendar_entries.where(
      ' entry_date BETWEEN :from AND :to ',
      { :from => self.date_from, :to => self.date_to }
    ).count

    duration = 0.00

    duration += (1 + (self.date_to - self.date_from).to_i) - weekend_days - holidays
    
    # subtract half day start/end
    duration -= 0.5 if self.half_day_from
    duration -= 0.5 if self.half_day_to

    # it's possible for negative values!
    #  e.g. dates are on a weekend which also has a public holiday  
    (duration < 0) ? 0 : duration
    
  end
  
  def update_duration
    write_attribute :duration, calculate_duration
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
  
  def same_date_half_day
    errors.add(:base, "From and to dates can't be the same and both be half day") if
      !(date_from.blank? || date_to.blank?) && (date_to == date_from) && (half_day_from && half_day_to)
  end

  def evaluate_constraints
    return if self.persisted? || !self.valid?

    # HACK: need to supply this for the constraint logic to work
    # NOTE: need to take time zone of client in account?
    write_attribute :created_at, Time.now

    LeaveConstraints::Base.evaluate(self).each do |constraint_name, value|
      write_attribute constraint_name.as_constraint, value
      write_attribute constraint_name.as_constraint_override, value
    end

  end

end
