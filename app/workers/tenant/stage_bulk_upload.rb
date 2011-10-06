require 'open-uri'
require 'aws/s3'
require 'csv'

module Tenant
  class StageBulkUpload < Struct.new(:upload_id)
  
    def perform()
      @bulk_upload = BulkUpload.find(self.upload_id)
      @account = @bulk_upload.account

      start_staging() && 
          stage_upload() && 
            validate_upload() && 
              complete_staging()
        
    rescue Exception => error
    
      # any errors will be raised here which fail the bulk upload
      # reload to clear any validation errors
      @bulk_upload.reload
    
      # log out the full error message
      logger.error error.message
      logger.error error.backtrace.join("\n")

      puts error.message
      puts error.backtrace.join("\n")

      # store the failure message
      fail_upload(error)

      false
    end
    
    private
    
    def start_staging()
      logger.info("#{@bulk_upload.id}: Started staging bulk upload.")
      @bulk_upload.set_as_staging
    end

    def stage_upload()
      logger.info("#{@bulk_upload.id}: Staging bulk upload.")
    
      # import the file as is into the bulk upload stage model

      line_number = 1
      options = { 
        :headers => :first_row, 
        :return_headers => true,
        :skip_blanks => true
      }
      
      ActiveRecord::Base.transaction do
      
        # ensure initial state (when retrying)
        @bulk_upload.records.clear

        CSV.foreach(open(@bulk_upload.authenticated_url), options) do |row|
        
          # skip if the row is empty or nil
          next unless row || row.fields.reject {|v| v.nil? }.empty?
                  
          if row.header_row?

            # verify header
            unless (row.fields - BulkUploadStage::VALID_FIELDS).empty?
              raise Exception.new("Invalid file header. The following unknown columns found:\n#{(row.fields - BulkUploadStage::VALID_FIELDS)}.\nAborting bulk upload!")
            end
          
          else
          
            bulk_upload_row = @bulk_upload.records.build(
              row.to_hash
            )
            bulk_upload_row.line_number = line_number
            
            # unlikely that this will fail
            unless bulk_upload_row.save
              raise Exception.new("Error on line #{line_number}: #{bulk_upload_row.errors.full_messages}")
            end
          
          end
          
          line_number += 1
                  
        end
  
        line_number
      end
    end

    def validate_upload()
      logger.info("#{@bulk_upload.id}: Validating bulk upload.")
    
      # validate each row, save the error message per row?
      # and raise an exception at the end to indicate failure
      # fault tolerant? skip problem rows?
      
      default_location = @account.location
      locations = @account.locations.inject({}) {|list, location| list[location.title.downcase] = location }
      
      default_department = @account.department
      departments = @account.departments.inject({}) {|list, department| list[department.title.downcase] = department }

      default_approver = @bulk_upload.uploaded_by 
      employees = @account.employees.inject({}) {|list, employee| list[employee.full_name.downcase] = employee }
      
      new_employees = @bulk_upload.records.inject({}) {|list, employee| list[employee.employee_name] = employee }

      ActiveRecord::Base.transaction do
        for record in @bulk_upload.records
        
          # resolve location, department and approver
          # check for duplicate employees
          # work out the load sequencing
          
          duplicate_employee = employees[record.employee_name]
          approver = employees[record.approver_first_and_last_name] || default_approver
          
          new_employee = nil
          if approver.nil?
            new_employee = new_employees[record.approver_first_and_last_name]
            new_employee.increment_load_sequence unless new_employee.nil?
          end
        
          selected, messages = record.validate_for_import
          
          messages += " - Approver not found" if approver.nil? && new_employee.nil?
          messages += " - Employee already exists" if duplicate_employee
          
          record.update_attributes!(
            :location => locations[record.location_name] || default_location,
            :department => locations[record.department_name] || default_department,
            :employee => duplicate_employee,            
            :approver => approver,
            :selected => selected & duplicate_employee.nil?,
            :messages => messages
          ) 
          
        end
        true
      end

    end

    def complete_staging()
      logger.info("#{@bulk_upload.id}: Completed staging bulk upload.")
      @bulk_upload.set_as_staged()
    end

    def fail_upload(error)
      logger.info("#{@bulk_upload.id}: Failed to stage bulk upload.")
      @bulk_upload.set_as_failed(
        Rails.env.production? ? 
          error.message :
          "#{error.message}\n#{error.backtrace.join("\n")}"
      )
    end

    def logger
      Delayed::Worker.logger
    end

  end
end

