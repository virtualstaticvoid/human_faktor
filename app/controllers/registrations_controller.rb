class RegistrationsController < ApplicationController
  include Rack::Recaptcha::Helpers
 
  def new
    @registration = Registration.new()
    @registration.partner = Partner.find(params[:partner]) if params[:partner]
  end

  def create
    @registration = Registration.new(params[:registration])
    
    if validate_recapture_and_save(@registration)
      redirect_to @registration, :notice => 'Registration successfully created.'
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
