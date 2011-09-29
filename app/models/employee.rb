require 'date'
require 'paper_clip_interpolations'

class Employee < ActiveRecord::Base
  include AccountScopedModel

  # include account in devise queries!

  def self.find_for_authentication(conditions = {})
    conditions[:account_id] = AccountTracker.current.id
    super
  end

  before_save :downcase_user_name

  default_scope order(:first_name, :last_name)
  
  scope :active_approvers, where(:active => true, :notify => true, :role => [:admin, :manager, :approver])

  # include devise modules
  devise :database_authenticatable, 
         :recoverable, 
         :rememberable, 
         :trackable, 
         #:timeoutable,
         :lockable,
         :token_authenticatable,
         :authentication_keys => [ :user_name ] 

  # system roles
  ROLE_ADMIN = :admin
  ROLE_MANAGER = :manager
  ROLE_APPROVER = :approver
  ROLE_EMPLOYEE = :employee 
  ROLES = [ ROLE_ADMIN, ROLE_MANAGER, ROLE_APPROVER, ROLE_EMPLOYEE ]
  
  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :role => ROLE_EMPLOYEE.to_s,
                 :fixed_daily_hours => 8,
                 :active => false,
                 :notify => false,
                 :take_on_balance_as_at => lambda { Date.today }

  belongs_to :location
  belongs_to :department
  belongs_to :approver, :class_name => 'Employee'
  
  has_many :leave_requests, :dependent => :destroy

  # identifier  
  validates :identifier, :presence => true, :uniqueness => true
  validates :user_name, :presence => true, 
                        :length => { :maximum => 20 },
                        :uniqueness => { :scope => [:account_id] }

  validates :email, :email => true, :allow_nil => lambda { self.notify != true }
  
   #, :uniqueness => { :scope => [:account_id] }
  
  # authentication
  validates :password, :confirmation => true, :length => { :in => 5..20 }, :allow_nil => true, :if => lambda { self.active }

  def has_password?
    self.encrypted_password.present?
  end
  
  # personal information
  validates :title, :allow_blank => true, :length => { :maximum => 20 }
  validates :first_name, :presence => true, :length => { :maximum => 100 }
  validates :middle_name, :allow_blank => true, :length => { :maximum => 20 }
  validates :last_name, :presence => true, :length => { :maximum => 100 }

  GENDER_MALE = 1
  GENDER_FEMALE = 2
  GENDERS = [GENDER_MALE, GENDER_FEMALE]
  
  validates :gender, :allow_nil => true,
            :numericality => { :only_integer => true, :in => GENDERS }

  def gender_filter
    self.gender ? [self.gender] : GENDERS
  end
  
  def gender_male?
    self.gender == GENDER_MALE
  end
  
  # contact details
  validates :telephone, :length => { :maximum => 20 }, :allow_nil => true
  validates :telephone_extension, :length => { :maximum => 10 }, :allow_nil => true
  validates :cellphone, :length => { :maximum => 20 }, :allow_nil => true

  # job information
  validates :internal_reference, :length => { :maximum => 255 }, :allow_nil => true
  validates :designation, :allow_blank => true, :length => { :maximum => 255 }
  validates :start_date, :timeliness => { :type => :date }, :allow_nil => true
  validates :end_date, :timeliness => { :type => :date }, :allow_nil => true
  validates :location, :existence => { :allow_nil => true }
  validates :department, :existence => { :allow_nil => true }
  validates :approver, :existence => { :allow_nil => true }

  # system settings

  def role_sym
    self.role.to_sym
  end

  validates :role, :presence => true, :inclusion => ROLES.collect {|role| role.to_s }

  def is_admin?
    self.role_sym == ROLE_ADMIN
  end

  def is_manager?
    self.role_sym == ROLE_MANAGER
  end

  def is_approver?
    self.role_sym == ROLE_APPROVER
  end
  
  def is_employee?
    self.role_sym == ROLE_EMPLOYEE
  end

  validates :fixed_daily_hours, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }
  
  def fixed_daily_hours_ratio
    self.fixed_daily_hours.to_f / self.account.fixed_daily_hours.to_f
  end
  
  validates :active, :inclusion => { :in => [true, false] }
  
  def active?
    self.active
  end
  
  def active_for_authentication?
    self.active
  end
  
  # notifications      
  validates :notify, :inclusion => { :in => [true, false] }

  def notify?
    self.email.present? && self.notify == true
  end

  # avatar for employee
  # NOTE: uses the ":account" interpolation
  # TODO: add validations for mime-type and file size
  has_attached_file :avatar, 
                    :styles => { :avatar => "48x48>" },
                    :url => Rails.env.production? ? 
                              "accounts/:account/employees/:identifier/avatar/:hash.:extension" :
                              "/system/accounts/:account/employees/:identifier/avatar/:hash.:extension",
                    :path => Rails.env.production? ? 
                              "accounts/:account/employees/:identifier/avatar/:hash.:extension" :
                              ":rails_root/accounts/:account/employees/:identifier/avatar/:hash.:extension",
                    :storage => Rails.env.production? ? :s3 : :filesystem,
                    :bucket => AppConfig.s3_bucket,
                    :s3_credentials => {
                      :access_key_id => AppConfig.s3_key,
                      :secret_access_key => AppConfig.s3_secret
                    },
                    :hash_secret => AppConfig.hash_secret

  # leave policy overrides
  LeaveType.for_each_leave_type_name do |leave_type_name|
    validates :"#{leave_type_name}_leave_cycle_allocation", :numericality => { :greater_than => 0 }, :allow_nil => true
    validates :"#{leave_type_name}_leave_cycle_carry_over", :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  end
  
  def leave_cycle_allocation_for(leave_type)
    self.send(:"#{leave_type.leave_type_name}_leave_cycle_allocation") || leave_type.cycle_days_allowance
  end

  # this is only applicable for annual leave*
  def leave_cycle_carry_over_for(leave_type)
    self.send(:"#{leave_type.leave_type_name}_leave_cycle_carry_over") || leave_type.cycle_days_carry_over
  end

  # take on balances
  validates :take_on_balance_as_at, :timeliness => { :type => :date }, :allow_nil => false
  validates_presence_of :take_on_balance_as_at, :if => lambda { self.has_take_on_balance }
  
  def effective_start_date
    # use the take on date
    #  then the start date
    # otherwise beginning of time...
    return self.take_on_balance_as_at unless self.take_on_balance_as_at.nil?
    return self.start_date unless self.start_date.nil?
    Date.new()
  end

  LeaveType.for_each_leave_type_name do |leave_type_name|
    default_value_for :"#{leave_type_name}_leave_take_on_balance", 0
    validates :"#{leave_type_name}_leave_take_on_balance", :numericality => true  
  end
  
  def has_take_on_balance
    LeaveType.for_each_leave_type_name do |leave_type_name|
      return true if read_attribute(:"#{leave_type_name}_leave_take_on_balance") != 0
    end
    false
  end
  
  def take_on_balance_for(leave_type)
    self.send(:"#{leave_type.leave_type_name}_leave_take_on_balance")
  end
  
  def leave_balance(leave_type, date_as_at = Date.today)
    LeaveBalanceDetail.new(leave_type, self, date_as_at)
  end

  def to_s
    [self.first_name, self.middle_name, self.last_name].reject {|n| n.blank? }.join(' ')
  end
  alias :full_name :to_s

  def to_param
    self.identifier
  end
  
  # permissions helpers
  
  def can_create_leave_for_other_employees?
    self.is_admin? || self.is_manager?
  end

  def can_authorise_leave?
    self.is_admin? || self.is_manager? || self.is_approver?
  end

  def can_choose_own_approver? 
    self.is_admin? || self.is_manager? || self.approver.nil? || !self.approver.active?
  end

  # employee lists
  
  # REFACTOR: to reduce number of database round trips
  def staff
    if self.is_admin?
      # admins, just return all employees
      self.account.employees 

    elsif self.is_manager?
      # manager, so build the hierarchy
      build_staff_list( self.account.employees.where(:approver_id => self.id) )
    
    elsif self.is_approver?
      # approver, so only direct staff
      self.account.employees.where(:approver_id => self.id).to_a

    else
      # ASSERT: self.employee? == true
      # employee, so no staff
      []
    end
  end
  
  def is_manager_of?(employee)
    employee.approver == self || self.staff.include?(employee)
  end

  # devise mailer callback
  def headers_for(action)
    {
      :subject => self.account.title + " " + I18n.t(:subject, :scope => [:devise, :mailer, action], :default => [:subject, action.to_s.humanize]),
      :reply_to => AppConfig.support_email
    }
  end

  # only applicable for managers
  def build_staff_list(direct_staff)
    # ASSERT: self.is_manager? == true
    
    staff = []
    direct_staff.each do |employee|
      
      staff << employee
      
      # skip if own approver
      next if self == employee
      
      # follow down for admins, managers and approvers
      unless employee.is_employee?
      
        # recurse to get staff of this employee  
        build_staff_list( self.account.employees.where(:approver_id => employee.id) ).each do |e| 
          staff << e unless staff.include?(e) 
        end
        
      end
    
    end
    
    staff.sort!{|a,b| a.full_name <=> b.full_name }
    
  end

  private
  
  def downcase_user_name
    self.user_name.downcase!
  end

end
