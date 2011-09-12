require 'date'

class Account < ActiveRecord::Base

  #
  # When the account is created initially, active is false
  # and the auth token is used to grant access to the system
  # admin in order to setup the account
  #

  default_scope order(:title)

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :theme => 'default',
                 :fixed_daily_hours => 8,
                 :active => false

  belongs_to :country
  belongs_to :location
  belongs_to :department

  has_many :account_subscriptions, :dependent => :destroy
  has_many :locations, :dependent => :destroy
  has_many :departments, :dependent => :destroy
  has_many :employees, :dependent => :destroy
  has_many :leave_types, :dependent => :destroy
  has_many :leave_requests, :dependent => :destroy
  has_many :leave_balances, :dependent => :destroy

  validates :identifier, :presence => true

  validates :subdomain, 
            :presence => true, 
            :uniqueness => true, 
            :subdomain => { :reserved => %w{about contact features subscriptions terms privacy partner sign_in sign_out registrations} }

  validates :title, :presence => true, :length => { :maximum => 255 }
  validates :theme, :presence => true
  
  # TODO: add validations for mime-type and file size
  has_attached_file :logo, 
                    :styles => { :logo => "140x60>" },
                    :path => Rails.env.production? ? 
                               "accounts/:identifier/logo/:hash.:extension" :
                               ":rails_root/accounts/:identifier/logo/:hash.:extension",
                    :storage => Rails.env.production? ? :s3 : :filesystem,
                    :bucket => AppConfig.s3_bucket,
                    :s3_credentials => {
                      :access_key_id => AppConfig.s3_key,
                      :secret_access_key => AppConfig.s3_secret
                    },
                    :hash_secret => AppConfig.hash_secret

  # access token for initial setup
  validates :auth_token, :presence => true

  # defaults  
  validates :country, :existence => true
  validates :location, :existence => { :allow_nil => true }
  validates :department, :existence => { :allow_nil => true }
  
  validates :fixed_daily_hours, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }

  validates :active, :inclusion => { :in => [true, false] }

  # cache leave types, so that validations work!
  LeaveType.for_each_leave_type do |leave_type_class|
    method_name = leave_type_class.name.underscore.gsub(/\//, '_')
    leave_type_name = leave_type_class.name.gsub(/LeaveType::/, '').downcase
    class_eval "def #{method_name}; @#{method_name} ||= self.leave_types.#{leave_type_name}; end", __FILE__, __LINE__
  end
  
#  def leave_types_valid?
#    valid = true
#    LeaveType.for_each_leave_type do |leave_type_class|
#      method_name = leave_type_class.name.underscore.gsub(/\//, '_')
#      valid &= self.send(method_name).valid?
#    end
#    valid
#  end

  def update_leave_type_attributes(attributes)
    with_transaction_returning_status do
      valid = true
      LeaveType.for_each_leave_type do |leave_type_class|
        method_name = leave_type_class.name.underscore.gsub(/\//, '_')
        leave_type = self.send(method_name)
        valid &= leave_type.update_attributes(attributes[method_name]) if attributes[method_name]
      end
      self.errors[:base] << "One or more leave policies are invalid." unless valid
      valid
    end
  end

  def to_param
    self.identifier
  end
  
  def to_s
    self.title
  end

  def registration
    @registration ||= Registration.find_by_auth_token(self.auth_token)
  end

  def leave_types_for_employee
    self.leave_types.where(:employee_capture_allowed => true).order(:type)
  end

  def leave_types_for_approver
    self.leave_types.where(:approver_capture_allowed => true).order(:type)
  end
  
  alias :leave_types_for_manager :leave_types_for_approver

  def leave_types_for_admin
    self.leave_types.where(:admin_capture_allowed => true).order(:type)
  end

end

