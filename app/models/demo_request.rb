class DemoRequest < ActiveRecord::Base

  belongs_to :country

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :country => lambda { Country.default },
                 :trackback => false

  validates :identifier, :presence => true, :uniqueness => true

  # contact details
  validates :first_name, :presence => true, :length => { :maximum => 255 }
  validates :last_name, :presence => true, :length => { :maximum => 255 }
  validates :email, :confirmation => true, :email => true
  
  validates :country, :existence => true

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

end
