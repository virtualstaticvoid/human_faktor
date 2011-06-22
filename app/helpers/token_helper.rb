module TokenHelper

  def self.friendly_token
    ActiveSupport::SecureRandom.base64(15).tr('+/=', 'xyz')
  end  

end
