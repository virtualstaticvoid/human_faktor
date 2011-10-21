class DemoRequestsController < ApplicationController
  include Rack::Recaptcha::Helpers

  skip_before_filter :ensure_account

  def new
    @demo_request = DemoRequest.new()
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