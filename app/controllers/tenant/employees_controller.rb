module Tenant
  class EmployeesController < AdminController
  
    def index
      filter_params = params[:employee_filter] || {}
      @filter = EmployeeFilter.new(current_account).tap do |c|
        c.filter_by = @filter_by = filter_params[:filter_by] || 'none'
        c.location_id = filter_params[:location_id] || current_employee.location_id
        c.department_id = filter_params[:department_id] || current_employee.department_id

        c.valid?
      end

      @employees = @filter.employees.page(params[:page])
    end
    alias filtered index

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
      load_leave_types
    end
    
    def update
      @employee = current_account.employees.find_by_identifier(params[:id])

      respond_to do |format|
        if @employee.update_attributes(params[:employee])
          format.html { redirect_to(employees_url, :notice => 'Employee was successfully updated.') }
        else
          load_leave_types
          format.html { render :action => "edit" }
        end
      end
    end
    
    def deactivate
      @employee = current_account.employees.find_by_identifier(params[:id])
    
      respond_to do |format|
        if @employee.update_attributes(:active => false)
          format.html { redirect_to(employees_url, :notice => 'Employee was successfully deactivated.') }
        else
          load_leave_types
          format.html { render :action => "edit" }
        end
      end
    end

    def reactivate
      @employee = current_account.employees.find_by_identifier(params[:id])
    
      respond_to do |format|
        if @employee.update_attributes(:active => true)
          format.html { redirect_to(employees_url, :notice => 'Employee was successfully re-activated.') }
        else
          load_leave_types
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
    
    def balance
      @employee = current_account.employees.find_by_identifier(params[:id])
      @date_as_at = ApplicationHelper.safe_parse_date(params[:as_at], Date.today)
      load_leave_types

      respond_to do |format|
        format.js   {}
      end
    end
    
    private
    
    def load_leave_types
      # get leave types, filtered by the gender of the employee
      @leave_types = current_account.leave_types.select {|leave_type| 
        !(leave_type.gender_filter & @employee.gender_filter).empty?
      }
    end
  
  end
end
