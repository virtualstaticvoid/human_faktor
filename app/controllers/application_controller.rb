class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :ensure_account
  
  helper_method :partials_path
  helper_method :current_account
  helper_method :safe_parse_date
  helper_method :current_leave_cycle_start_date
  helper_method :current_leave_cycle_end_date

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || (resource.leave_requests.count() == 0 ? welcome_path : dashboard_path)
  end

  def after_sign_out_path_for(resource)
    new_employee_session_path
  end

  private
  
  def partials_path
    return 'shared' unless defined?(@partials_path)
    @partials_path
  end

  attr_writer :partials_path
  
  def current_account
    AccountTracker.current
  end

  def safe_parse_date(value, default = nil)
    Date.parse(value)
  rescue
    default
  end

  def current_leave_cycle_start_date(for_date = Date.today)
    current_account.annual.current_cycle_start_date_for(for_date)
  end

  def current_leave_cycle_end_date(for_date = Date.today)
    current_account.annual.current_cycle_end_date_for(for_date)
  end

  def ensure_account
    AccountTracker.current = Account.find_by_subdomain(params[:tenant]) unless params[:tenant].nil?
    redirect_to(home_sign_in_url) and return false if current_account.nil?
    
    # check that employee belongs to this account
    sign_out(current_employee) and return false if employee_signed_in? && current_employee.account != current_account
    
    true
  end
  
  def ensure_admin
    redirect_to(dashboard_url, :notice => 'You need to be an administrator to perform this action.') and return false unless current_employee.is_admin?
    true
  end

  def ensure_manager
    redirect_to(dashboard_url, :notice => 'You need to be an manager to perform this action.') and return false unless current_employee.is_manager?
    true
  end

  def ensure_approver
    redirect_to(dashboard_url, :notice => 'You need to be an approver to perform this action.') and return false unless current_employee.is_approver?
    true
  end

end

