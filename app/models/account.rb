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
  belongs_to :partner

  has_many :account_subscriptions, :dependent => :destroy
  has_many :locations, :dependent => :destroy
  has_many :departments, :dependent => :destroy
  has_many :employees, :dependent => :destroy
  has_many :leave_types, :dependent => :destroy
  has_many :leave_requests, :dependent => :destroy

  # cache leave types, so that validations work!
  LeaveType.for_each_leave_type do |leave_type_class|
    method_name = leave_type_class.name.underscore.gsub(/\//, '_')
    leave_type_name = leave_type_class.name.gsub(/LeaveType::/, '').downcase
    class_eval "def #{method_name}; @#{method_name} ||= self.leave_types.#{leave_type_name}; end", __FILE__, __LINE__
  end

  validates :identifier, :presence => true

  validates :subdomain, 
            :presence => true, 
            :uniqueness => true, 
            :subdomain => true

  validates :title, :presence => true, :length => { :maximum => 255 }
  validates :country, :presence => true, :existence => true
  validates :partner, :existence => { :allow_nil => true }

  # TODO: add validations for mime-type and file size
  has_attached_file :logo, 
                    :styles => { :logo => "140x60>" },
                    :path => "accounts/:id/logo/:filename",
                    :storage => :s3,
                    :bucket => AppConfig.s3_bucket,
                    :s3_credentials => {
                      :access_key_id => AppConfig.s3_key,
                      :secret_access_key => AppConfig.s3_secret
                    }

  validates :fixed_daily_hours, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }

  validates :active, :inclusion => { :in => [true, false] }

  # access token for initial setup
  validates :auth_token, :presence => true

  def to_param
    self.identifier
  end

  # intercept in order to update leave types
  def update_attributes(attributes)
    with_transaction_returning_status do
      valid = super
      LeaveType.for_each_leave_type do |leave_type_class|
        method_name = leave_type_class.name.underscore.gsub(/\//, '_')
        leave_type = self.send(method_name)
        valid &= leave_type.update_attributes(attributes[method_name]) if attributes[method_name]
      end
      self.errors[:base] << "One or more leave policies are invalid." unless valid
      valid
    end
  end

end

