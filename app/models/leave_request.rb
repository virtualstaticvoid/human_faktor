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
  STATUSES = [STATUS_NEW, STATUS_PENDING, STATUS_APPROVED, STATUS_DECLINED, STATUS_CANCELLED]

  @@statuses = []
  @@status_names = {}

  LeaveRequest.constants.each do |constant|
    next unless constant =~ /^STATUS_/
    
    constant_value = LeaveRequest.const_get(constant)
    @@statuses << constant_value
    @@status_names[constant_value] = constant.to_s.gsub(/STATUS_/, '').downcase
    
    define_method "#{constant.downcase}?" do
      self.status == constant_value
    end
    
  end
  
  default_scope order('created_at DESC')

  scope :pending, where(:status => STATUS_PENDING)
  scope :active, where(:status => [STATUS_PENDING, STATUS_APPROVED])

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :status => STATUS_NEW,
                 :half_day_from => false,
                 :half_day_to => false,
                 :unpaid => false

  belongs_to :employee
  belongs_to :leave_type
  belongs_to :approver, :class_name => 'Employee'

  validates :identifier, :presence => true, :uniqueness => true

  validates :employee, :presence => true, :existence => true
  validates :leave_type, :presence => true, :existence => true

  validates :status, 
            :presence => true, 
            :numericality => { :only_integer => true, :in => @@statuses }

  def status_text
    @@status_names[self.status].capitalize
  end                                                          

  validates :approver, :presence => true, :existence => true
  
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
  
  #validates :comment

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

  # description for calendar tooltips
  def description
    "#{self.leave_type} - #{self.employee.full_name} - #{self.status_text}"
  end
  
  def duration
  
    # subtract weekends and holidays!
    
    weekend_days = (self.date_from..self.date_to).select {|d| [6, 0].include?(d.wday) }.count
    
    holidays = self.account.country.calendar_entries.where(
      ' entry_date BETWEEN :from AND :to ',
      { :from => self.date_from, :to => self.date_to }
    ).count

    duration = (1 + (self.date_to - self.date_from).to_i) - weekend_days - holidays
    
    # subtract half day start/end
    duration -= 0.5 if self.half_day_from
    duration -= 0.5 if self.half_day_to
    
    # it's possible for negative values!
    #  e.g. dates are on a weekend which also has a public holiday  
    duration < 0 ? 0 : duration
    
  end
  
  #
  # Constraints
  #
  def has_constraint_violations?
    # TODO
    true
  end

  # use the identifier for security
  #  users can't guess the number now :-)
  def to_param
    self.identifier
  end
  
  #
  # Actions
  #
  
  def confirm
    # TODO  
    write_attribute :status, STATUS_PENDING
  end
  
  def approve
    # TODO  
    write_attribute :status, STATUS_APPROVED
  end
  
  def decline
    # TODO  
    write_attribute :status, STATUS_DECLINED
  end
  
  def cancel
    # TODO  
    write_attribute :status, STATUS_CANCELLED
  end

  # test helpers
  %w{confirm approve decline cancel}.each do |action|
    define_method "#{action}!" do
      self.send(action)
      self.save!
    end
  end
  
  # permissions
  
  def can_authorise?(employee)
    # TODO
    
    false
  end

  def can_cancel?(employee)
    # TODO
    
    false
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

end
