class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :get_account
  
  helper_method :partials_path
  helper_method :current_account
  
  private
  
  def partials_path
    return 'shared' unless defined?(@partials_path)
    @partials_path
  end

  attr_writer :partials_path
  
  def get_account
    AccountTracker.current = Account.find_by_subdomain(params[:tenant]) unless params[:tenant].nil?
  end

  def current_account
    AccountTracker.current
  end

  def ensure_account
    redirect_to home_sign_in_url and return false if current_account.nil?
    true
  end
  
  def ensure_admin
    redirect_to(dashboard_path, :notice => 'You need to be an administrator to perform this action.') and return false unless current_employee.is_admin?
    true
  end

  def ensure_manager
    redirect_to(dashboard_path, :notice => 'You need to be an manager to perform this action.') and return false unless current_employee.is_manager?
    true
  end

  def ensure_approver
    redirect_to(dashboard_path, :notice => 'You need to be an approver to perform this action.') and return false unless current_employee.is_approver?
    true
  end

end

