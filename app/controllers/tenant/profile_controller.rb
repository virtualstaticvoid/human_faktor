module Tenant
  class ProfileController < DashboardController

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
    
    private 
    
    def load_leave_types

      # filter by employee capture permissions and the gender of the employee
      @leave_types = current_account.leave_types_for_employee.select {|leave_type| 
        !(leave_type.gender_filter & current_employee.gender_filter).empty?
      }

    end
    
  end
end
