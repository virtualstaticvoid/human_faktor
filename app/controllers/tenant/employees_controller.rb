module Tenant
  class EmployeesController < AdminController
  
    def index
      @employees = current_account.employees.page(params[:page])
    end
    
    def new
      @employee = Employee.new

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
      employee_params = params[:employee]

      # blank password?
      unless employee_params[:password].present?
        employee_params.delete(:password) 
        employee_params.delete(:password_confirmation) 
      end

      respond_to do |format|
        if @employee.update_attributes(employee_params)
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
