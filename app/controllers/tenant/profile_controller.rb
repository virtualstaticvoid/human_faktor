module Tenant
  class ProfileController < TenantController
    layout 'dashboard'

    skip_before_filter :check_employee, :only => [:activate, :setactive]

    # NNB: can only edit personal information, so remove any other params!
    PARAMS_ALLOWED = [
      :avatar,
      :title, 
      :first_name, 
      :middle_name, 
      :last_name, 
      :gender, 
      :password, 
      :password_confirmation, 
      :notify, 
      :email,
      :telephone,
      :telephone_extension,
      :cellphone
    ]

    def edit
      @employee = current_employee
      load_leave_types
    end

    def update
      @employee = current_employee
      load_leave_types
      
      # filter out any params not allowed!
      employee_params = params[:employee].keep_if {|key, value| PARAMS_ALLOWED.include?(key.to_sym) }
      
      # blank password?
      unless employee_params[:password].present?
        employee_params.delete(:password) 
        employee_params.delete(:password_confirmation) 
      end

      respond_to do |format|
        if @employee.update_attributes(employee_params)
          sign_in(@employee, :bypass => true) if employee_params[:password].present? 
          format.html { redirect_to(profile_url, :notice => 'Profile was successfully updated.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    def activate
      @employee = current_employee
      redirect_to dashboard_url and return if @employee.has_password?
      render :action => :activate, :layout => "basic"
    end
    
    def setactive
      @employee = current_employee
      
      # filter out any params not allowed!
      employee_params = params[:employee].keep_if {|key, value| [:password, :password_confirmation].include?(key.to_sym) }

      respond_to do |format|
        if @employee.update_attributes(employee_params)
          sign_in(@employee, :bypass => true)
          format.html { redirect_to(dashboard_url, :notice => 'Profile was successfully activated.') }
        else
          format.html { render :action => :activate, :layout => "basic" }
        end
      end
    end

    private 
    
    def load_leave_types

      # filter by employee's gender
      @leave_types = current_account.leave_types.select {|leave_type| 
        !(leave_type.gender_filter & current_employee.gender_filter).empty?
      }

    end
    
  end
end
