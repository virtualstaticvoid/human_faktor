class Employee < ActiveRecord::Base
  include AccountScopedModel

  before_save :downcase_user_name

  default_scope order(:first_name, :last_name)

  # include devise modules
  devise :database_authenticatable, 
         :recoverable, 
         :rememberable, 
         :trackable, 
         :timeoutable,
         :lockable,
         :token_authenticatable

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
                 :notify => false

  belongs_to :location
  belongs_to :department

  # identifier  
  validates :identifier, :presence => true, :uniqueness => true
  validates :user_name, :presence => true, :uniqueness => { :scope => [:account_id] }
  validates :email, :email => true
  
  # authentication
  validates :password, :allow_nil => true,
            :confirmation => true, :length => { :in => 5..20 }

  # personal information
  validates :title, :allow_blank => true, :length => { :maximum => 20 }
  validates :first_name, :presence => true, :length => { :maximum => 100 }
  validates :middle_name, :allow_blank => true, :length => { :maximum => 20 }
  validates :last_name, :presence => true, :length => { :maximum => 100 }

  GENDER_MALE = 1
  GENDER_FEMALE = 2
  
  validates :gender, :allow_nil => true,
            :numericality => { :only_integer => true, :in => [ GENDER_MALE, GENDER_FEMALE ] }

  # job information
  validates :designation, :allow_blank => true, :length => { :maximum => 255 }
  validates :start_date, :timeliness => { :type => :date }, :allow_nil => true
  validates :end_date, :timeliness => { :type => :date }, :allow_nil => true
  validates :location, :presence => true, :existence => true
  validates :department, :presence => true, :existence => true

  # system settings

  def role_sym
    self.role.to_sym
  end

  validates :role_sym, :presence => true, :inclusion => ROLES

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
  validates :active, :inclusion => { :in => [true, false] }
  
  def active?
    self.active
  end
  
  # notifications      
  validates :notify, :inclusion => { :in => [true, false] }

  def notify?
    self.notify == true
  end

  # avatar for employee
  # NNB: uses the ":account" interpolation
  has_attached_file :avatar, 
                    :styles => { :avatar => "48x48>" },
                    :path => "accounts/:account/employees/:id/avatar/:filename",
                    :storage => :s3,
                    :bucket => AppConfig.s3_bucket,
                    :s3_credentials => {
                      :access_key_id => AppConfig.s3_key,
                      :secret_access_key => AppConfig.s3_secret
                    }

  def to_s
    "#{self.first_name} #{self.last_name}"
  end

  def to_param
    self.identifier
  end
  
  # permissions helpers
  
  def can_create_leave_for_other_employees?
    self.is_admin? || self.is_manager?
  end

  def can_approve_decline_or_cancel_leave
    self.is_admin? || self.is_manager? || self.is_approver?
  end

  def can_choose_own_approver? 
    self.is_admin? || self.is_manager? || self.approver.nil? || !self.approver.active?
  end

  # employee lists
  
  def approver_for
    self.account.employees.where(:approver_id => self.id)
  end
  
  # REFACTOR: to reduce number of database round trips
  def manager_for
    staff = []
    is_admin_or_manager = self.is_admin? || self.is_manager?
    self.approver_for.each do |employee|
      staff << employee
      staff << employee.manager_for unless self == employee if is_admin_or_manager
    end
    staff.flatten
  end
  
  def is_manager_of?(employee)
    self.approver == employee || 
    employee.approver == self ||
    !self.manager_for.index(employee).nil?
  end

  private
  
  def downcase_user_name
    self.user_name.downcase!
  end

end