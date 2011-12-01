class TenantAdmin < ActiveRecord::Base

  # include devise modules
  devise :database_authenticatable, 
         :recoverable, 
         :rememberable, 
         :trackable, 
         #:timeoutable,
         :lockable,
         :token_authenticatable,
         :authentication_keys => [ :user_name ] 

  default_values :identifier => lambda { TokenHelper.friendly_token },
                 :active => true

  validates :identifier, :presence => true, :uniqueness => true

  validates :user_name, :presence => true, 
                        :length => { :maximum => 50 },
                        :uniqueness => { :case_sensitive => false }

  validates :email, :email => true, 
                    :length => { :maximum => 255 }

  validates :password, :confirmation => true, 
                       :length => { :in => 5..20 }, 
                       :if => lambda { self.active }

  validates :active, :inclusion => { :in => [true, false] }
  
  def active?
    self.active
  end
  
  def active_for_authentication?
    self.active
  end
  
end