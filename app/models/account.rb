require 'date'

class Account < ActiveRecord::Base

  #
  # When the account is created initially, active is false
  # and the auth token is used to grant access to the system
  # admin in order to setup the account
  #

  default_scope order(:title)

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :fixed_daily_hours => 8,
                 :active => false

  belongs_to :country
  belongs_to :partner

  has_many :account_subscriptions, :dependent => :destroy

  validates :identifier, :presence => true

  validates :subdomain, 
            :presence => true, 
            :uniqueness => true, 
            :subdomain => true

  validates :title, :presence => true, :length => { :maximum => 255 }
  validates :country, :presence => true, :existence => true
  validates :partner, :existence => { :allow_nil => true }

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

end

