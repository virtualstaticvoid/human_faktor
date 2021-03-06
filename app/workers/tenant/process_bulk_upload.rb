require 'action_view/helpers/text_helper'

module Tenant
  class ProcessBulkUpload < Struct.new(:upload_id)
    include ActionView::Helpers::TextHelper
  
    def perform()
      log "Processing bulk upload"

      @bulk_upload = BulkUpload.find(self.upload_id)
      @account = @bulk_upload.account

      start_processing() && 
        apply_upload() && 
          complete_processing()
          
      log "Processed #{pluralize(@bulk_upload.records.count(), 'employee')}."
      true

    rescue Exception => error
    
      # any errors will be raised here which fail the bulk upload
      @bulk_upload.reload
    
      # log out the full error message
      log error.message
      log error.backtrace.join("\n")

      # store the failure message
      fail_upload(error)

      false
    end

    private

    def start_processing()
      log "Started processing bulk upload."
      @bulk_upload.set_as_processing
    end
    
    def apply_upload()
      log "Processing bulk upload."

      default_approver_id = @bulk_upload.uploaded_by_id
      employees = @account.employees

      new_employees = {}
      employees_needing_approvers = {}
      
      ActiveRecord::Base.transaction do
        
        # load new employees in sequence
        for record in @bulk_upload.records.selected.order('load_sequence DESC')
        
          employee = employees.build(
          
            :user_name => record.user_name,
            :email => record.email,

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
          
          # save with validation, and fail if needed!
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

      end

    rescue Exception => exception

      log exception

      employees.reload  # discard any changes
      @account.reload

      # re-raise it!
      raise exception
    
    end
  
    def complete_processing()
      log "Completed processing bulk upload."
      @bulk_upload.set_as_processed()
    end

    def fail_upload(error)
      log "Failed to process bulk upload."
      @bulk_upload.set_as_failed(
        Rails.env.production? ? 
          error.message :
          "#{error.message}\n#{error.backtrace.join("\n")}"
      )
    end
    
    private

    def log(message)
      puts "#{self.upload_id}: #{message}" if Rails.env.development?
      logger.info "#{self.upload_id}: #{message}"
    end

    def logger
      @logger ||= if defined?(Rails)
        Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      else
        Logger.new(STDOUT)
      end
    end

  end
end

