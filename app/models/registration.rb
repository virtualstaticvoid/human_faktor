class Registration < ActiveRecord::Base

  before_save :downcase_subdomain

  default_scope order(:title)

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :auth_token => lambda { TokenHelper.friendly_token },
                 :country => lambda { Country.default },
                 :active => false

  belongs_to :country
  belongs_to :subscription
  belongs_to :partner

  validates :identifier, :presence => true

  validates :subdomain, 
            :presence => true, 
            :uniqueness => true, 
            :subdomain => true
  
  validates :title, :presence => true, :length => { :maximum => 255 }
  validates :email, :confirmation => true, :email => true
  validates :country, :presence => true, :existence => true
  validates :subscription, :presence => true, :existence => true
  validates :partner, :existence => { :allow_nil => true }
  validates :auth_token, :presence => true
  validates :active, :inclusion => { :in => [true, false] }
  
  def application_url
    "https://#{self.subdomain}.#{AppConfig.domain}/#{self.auth_token}"
  end

  def to_param
    self.identifier
  end

  private
  
  def downcase_subdomain
    self.subdomain.downcase!
  end

end
