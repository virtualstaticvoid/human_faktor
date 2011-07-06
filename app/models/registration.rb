class Registration < ActiveRecord::Base

  before_save :downcase_subdomain

  default_scope order(:title)

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :auth_token => lambda { TokenHelper.friendly_token },
                 :country => lambda { Country.default },
                 :subscription => lambda { Subscription.default },
                 :active => false

  belongs_to :country
  belongs_to :subscription
  belongs_to :partner

  validates :identifier, :presence => true, :uniqueness => true

  validates :subdomain, 
            :presence => true, 
            :uniqueness => true, 
            :subdomain => true
  
  validates :title, :presence => true, :length => { :maximum => 255 }
  
  # contact details
  validates :first_name, :presence => true, :length => { :maximum => 255 }
  validates :last_name, :presence => true, :length => { :maximum => 255 }
  validates :email, :confirmation => true, :email => true
  
  validates :country, :existence => true
  validates :subscription, :existence => true
  validates :partner, :existence => { :allow_nil => true }
  validates :active, :inclusion => { :in => [true, false] }

  # access token for initial setup
  validates :auth_token, :presence => true
  
  def to_param
    self.identifier
  end
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def user_name
    "#{clean(self.first_name)}.#{clean(self.last_name)}".downcase
  end
  
  private
  
  def downcase_subdomain
    self.subdomain.downcase!
  end
  
  def clean(str)
    str.gsub(/[^(A-Z|a-z|0-9)]/i, '')
  end

end
