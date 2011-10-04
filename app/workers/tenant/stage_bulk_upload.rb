require 'aws/s3'
require 'csv'

module Tenant
  class StageBulkUpload < Struct.new(:upload_id)
  
    def perform()
      @bulk_upload = BulkUpload.find(self.upload_id)
      @account = @bulk_upload.account

      start_upload() && 
        stage_upload() && 
          validate_upload() && 
              complete_staging()
        
    rescue Exception => error
    
      # any errors will be raised here which fail the bulk upload
    
      # log out the full error message
      Rails.logger.error error.message
      Rails.logger.error error.backtrace.join("\n")

      # store the failure message
      fail_upload(error)

      false
    end
    
    private
    
    def start_upload()
      @bulk_upload.set_as_processing
    end

    def stage_upload()
    
      # import the file as is into the bulk upload stage model

      line_number = 1
      options = { 
        :headers => :first_row, 
        :return_headers => true,
        :skip_blanks => true
      }
      
      ActiveRecord::Base.transaction do

        CSV.foreach(@bulk_upload.authenticated_url, options) do |row|
          next unless row
                  
          if row.header_row?

            # verify header
            unless (row.fields - BulkUploadStage::VALID_FIELDS) == []
              raise Exception.new("Invalid file header. The following unknown columns found:\n#{(row.fields - BulkUploadStage::VALID_FIELDS)}.\nAborting bulk upload!")
            end
          
          else
          
            bulk_upload_row = @bulk_upload.records.build(row.to_hash)
            bulk_upload_row.line_number = line_number
            
            # unlikely that this will fail
            unless bulk_upload_row.save
              raise Exception.new("Error on line #{line_number}: #{bulk_upload_row.errors.full_messages}")
            end
          
          end
          
          line_number += 1
                  
        end
  
        true
      end
    end

    def validate_upload()
    
      # validate each row, save the error message per row?
      # and raise an exception at the end to indicate failure
      # fault tolerant? skip problem rows?
      
      default_location = @account.locations.default
      locations = @account.locations.inject({}) {|list, location| list[location.name.downcase] = location }
      
      default_department = @account.departments.default
      departments = @account.departments.inject({}) {|list, department| list[department.name.downcase] = department }

      default_approver = @bulk_upload.uploaded_by 
      employees = @account.employees.inject({}) {|list, employee| list[employee.full_name.downcase] = employee }
      
      @bulk_upload.reload

      ActiveRecord::Base.transaction do
        for record in @bulk_upload.records
        
          # resolve location, department and approver
          # check for duplicate employees
          # work out the load sequencing
        
          selected, messages = record.validate_for_import
          record.update_attributes(
            :location => locations[record.location_name] || default_location,
            :department => locations[record.department_name] || default_department,
            :employee => employees[record.employee_name],            
            :approver => employees[record.approver_first_and_last_name] || default_approver,
            :selected => selected,
            :messages => messages
          ) 
          
        end
        true
      end

    end

    def complete_staging()
      @bulk_upload.set_as_checked()
    end

    def fail_upload(error)
      @bulk_upload.set_as_failed(
        Rails.env.production? ? 
          error.message :
          "#{error.message}\n#{error.backtrace.join("\n")}"
      )
    end

  end
end

