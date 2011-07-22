module Tenant
  class EmployeesController < AdminController
  
    def index
      @employees = current_account.employees.page(params[:page])
    end
    
    def new
      @employee = Employee.new(
        :location_id => current_account.location_id,
        :department_id => current_account.department_id,
        :fixed_daily_hours => current_account.fixed_daily_hours
      )

      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    def create
      @employee = current_account.employees.build(params[:employee])

      respond_to do |format|
        if @employee.save
          format.html { redirect_to(employees_url, :notice => 'Employee was successfully created.') }
        else
          format.html { render :action => "new" }
        end
      end
    end
    
    def edit
      @employee = current_account.employees.find_by_identifier(params[:id])
    end
    
    def update
      @employee = current_account.employees.find_by_identifier(params[:id])

      respond_to do |format|
        if @employee.update_attributes(params[:employee])
          format.html { redirect_to(employees_url, :notice => 'Employee was successfully updated.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    def destroy
      @employee = current_account.employees.find_by_identifier(params[:id])
      @employee.destroy
    
      respond_to do |format|
        format.html { redirect_to(employees_url, :notice => 'Employee was successfully deleted.') }
        format.js   {}
      end
    end
  
  end
end
