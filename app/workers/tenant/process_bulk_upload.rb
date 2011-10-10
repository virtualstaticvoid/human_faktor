module Tenant
  class ProcessBulkUpload < Struct.new(:upload_id)
  
    def perform()
      @bulk_upload = BulkUpload.find(self.upload_id)
      @account = @bulk_upload.account

      start_processing() && 
        apply_upload() && 
          complete_processing()

    rescue Exception => error
    
      # any errors will be raised here which fail the bulk upload
    
      # log out the full error message
      puts error.message
      puts error.backtrace.join("\n")

      # store the failure message
      fail_upload(error)

      false
    end

    private

    def start_processing()
      puts "#{@bulk_upload.id}: Started processing bulk upload."
      @bulk_upload.set_as_processing
    end
    
    def apply_upload()
      puts "#{@bulk_upload.id}: Processing bulk upload."

      ActiveRecord::Base.transaction do
        
        default_approver_id = @bulk_upload.uploaded_by_id
        employees = @account.employees

        new_employees = {}
        employees_needing_approvers = {}
        
        # load new employees in sequence
        for record in @bulk_upload.records.selected.order('load_sequence DESC')
        
          employee = employees.build(
          
            :user_name => record.user_name,
            :email => record.email.blank? ? nil : record.email,

            :title => record.title,
            :first_name => record.first_name,
            :middle_name => record.middle_name,
            :last_name => record.last_name,
            
            :gender => ( case record.gender.downcase
                           when 'm' then Employee::GENDER_MALE
                           when 'f' then Employee::GENDER_FEMALE 
                         end),

            :internal_reference => record.reference,
            :telephone => record.telephone,
            :telephone_extension => record.telephone_extension,
            :cellphone => record.mobile,
            
            :designation => record.designation,
            :start_date => record.start_date,

            :location_id => record.location_id,
            :department_id => record.department_id,
            
            # use the default for now...
            :approver_id => record.approver_id || default_approver_id,
            
            :role => ( case record.role.downcase
                         when 'admin' then Employee::ROLE_ADMIN
                         when 'manager' then Employee::ROLE_MANAGER
                         when 'approver' then Employee::ROLE_APPROVER
                         else Employee::ROLE_EMPLOYEE
                       end ).to_s,
            
            :active => true,
            :notify => !record.email.blank?,

            :take_on_balance_as_at => record.take_on_balance_as_at,
            :annual_leave_take_on_balance => record.annual_leave_take_on.to_f,
            :educational_leave_take_on_balance => record.educational_leave_take_on.to_f,
            :medical_leave_take_on_balance => record.medical_leave_take_on.to_f,
            :maternity_leave_take_on_balance => record.maternity_leave_take_on.to_f,
            :compassionate_leave_take_on_balance => record.compassionate_leave_take_on.to_f
          )
          
          employee.save!
          
          employees_needing_approvers[employee] = record unless record.new_approver_id.nil?
          new_employees[employee.full_name.downcase] = employee
          
        end
        
        # fix up approvers
        employees_needing_approvers.each do |employee, record|
          employee.update_attributes!(
            :approver => new_employees[record.approver_first_and_last_name.downcase]
          )
        end
        
        @account.save!
      end      
    end
  
    def complete_processing()
      puts "#{@bulk_upload.id}: Completed processing bulk upload."
      @bulk_upload.set_as_processed()
    end

    def fail_upload(error)
      puts "#{@bulk_upload.id}: Failed to process bulk upload."
      @bulk_upload.set_as_failed(
        Rails.env.production? ? 
          error.message :
          "#{error.message}\n#{error.backtrace.join("\n")}"
      )
    end
    
  end
end

