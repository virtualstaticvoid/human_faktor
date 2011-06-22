class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :partials_path
  
  private
  
  def partials_path
    return 'shared' unless defined?(@partials_path)
    @partials_path
  end

  attr_writer :partials_path

end
