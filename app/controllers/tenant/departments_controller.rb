module Tenant
  class DepartmentsController < AdminController
  
    def index
      @departments = current_account.departments.page(params[:page])
    end
    
    def new
      @department = Department.new

      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    def create
      @department = current_account.departments.build(params[:department])

      respond_to do |format|
        if @department.save
          format.html { redirect_to(departments_url(:tenant => current_account.subdomain), :notice => 'Department was successfully created.') }
        else
          format.html { render :action => "new" }
        end
      end
    end
    
    def edit
      @department = current_account.departments.find(params[:id])
    end
    
    def update
      @department = current_account.departments.find(params[:id])

      respond_to do |format|
        if @department.update_attributes(params[:department])
          format.html { redirect_to(departments_url(:tenant => current_account.subdomain), :notice => 'Department was successfully updated.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    def destroy
      @department = current_account.departments.find(params[:id])
      @department.destroy
    
      respond_to do |format|
        format.html { redirect_to(departments_url(:tenant => current_account.subdomain), :notice => 'Department was successfully deleted.') }
        format.js   {}
      end
    end
  
  end
end
