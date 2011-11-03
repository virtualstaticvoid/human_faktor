require 'geoip'

class RegistrationsController < ApplicationController
  include Rack::Recaptcha::Helpers

  skip_before_filter :ensure_account
 
  def new
    @registration = Registration.new()
    
    @registration.subscription = Subscription.where(
      :max_employees => params[:subscription]
    ).where('price > 0').first if params[:subscription]
    
    @registration.partner = Partner.find(params[:partner]) if params[:partner]

    # use Geo IP to figure out the country from the IP address
    geoinf = GeoIP.new(File.join(Rails.root, 'db', 'geoip.dat')).country(request.remote_ip)
    @registration.country = Country.by_iso_code(geoinf.country_code2) || @registration.country

  end

  def create
    @registration = Registration.new(params[:registration])
    @registration.source_url = request.url
    
    if validate_recapture_and_save(@registration)
      redirect_to account_registration_path(@registration)
    else
      render :action => :new
    end
  end
  
  def show
    @registration = Registration.find_by_identifier(params[:id])
  end
  
  def query
    @time_elapsed = Time.now - Time.parse(params[:started])
    @registration = Registration.find_by_identifier(params[:id])
  end
  
  private

  def validate_recapture_and_save(registration)
    if recaptcha_valid?
      registration.save
    else
      registration.valid?
      registration.errors.add :base, 'ReCaptcha verification is incorrect, please try again.'
      false
    end
  end

end
