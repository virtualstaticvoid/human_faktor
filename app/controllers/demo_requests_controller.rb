require 'geoip'

class DemoRequestsController < ApplicationController
  include Rack::Recaptcha::Helpers

  skip_before_filter :ensure_account

  def new
    @demo_request = DemoRequest.new()
  
    # use Geo IP to figure out the country from the IP address
    geoinf = GeoIP.new(File.join(::Rails.root, 'db', 'geoip.dat')).country(request.remote_ip)
    @demo_request.country = Country.by_iso_code(geoinf.country_code2) || @demo_request.country

  end

  # POST
  def create
    @demo_request = DemoRequest.new(params[:demo_request])

    if validate_recapture_and_save(@demo_request)
      redirect_to root_url, :notice => 'Thank you. You will receive an email shortly with a link to the demo.'
    else
      render :new
    end
  end

  private

  def validate_recapture_and_save(demo_request)

    # skip recapcha verification for now...
    demo_request.save
    
    # if recaptcha_valid?
    #   demo_request.save
    # else
    #   demo_request.valid?
    #   demo_request.errors.add :base, 'ReCaptcha verification is incorrect, please try again.'
    #   false
    # end
  end

end