require 'geoip'

class HomeController < ApplicationController

  skip_before_filter :ensure_account

  def index
  end

  def contact
  end

  def terms
  end
  
  def privacy
  end

  def features
  end

  def subscriptions
    
    @default_subscription = Subscription.default
    @subscriptions = Subscription.active.where('price > 0')

    # use the country parameter
    if params[:country].present?
      @country = Country.by_iso_code(params[:country]) || Country.by_iso_code('za')
    else

      # see http://www.maxmind.com/app/country and http://www.maxmind.com/app/ruby for more details

      # use Geo IP to figure out the country from the IP address
      geoinf = GeoIP.new(File.join(Rails.root, 'db', 'geoip.dat')).country(request.remote_ip)

      #
      # For now, only interested in whether the request is from South Africa
      #  otherwise, we use USA as the country
      #
      @country = (geoinf.country_code2 == "ZA") ? 
                    Country.by_iso_code('za') :
                    Country.by_iso_code('us') 

    end

  end

  def partner
  end

  def sign_in
  end
  
end
