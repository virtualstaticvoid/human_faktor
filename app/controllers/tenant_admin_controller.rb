class TenantAdminController < ApplicationController

  skip_before_filter :ensure_account
  before_filter :authenticate_tenant_admin!

  def index
    @accounts = Kaminari.paginate_array(Account.all.to_a.sort {|a, b| -1 * (a.updated_at <=> b.updated_at) }).page(params[:page])
  end

  def show
    @account = Account.find_by_identifier(params[:id])
  end
  
  def impersonate
    employee = Employee.find_by_identifier(params[:id])
    sign_in(:employee, employee)
    redirect_to dashboard_url(:tenant => employee.account.subdomain)
  end

end