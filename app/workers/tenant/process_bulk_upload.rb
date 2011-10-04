require 'aws/s3'
require 'csv'

module Tenant
  class ProcessBulkUpload < Struct.new(:upload_id)
  
    VALID_FIELDS = %w{      
      reference
      title
      first_name
      middle_name
      last_name
      gender
      email
      telephone
      mobile
      designation
      start_date
      location_name
      department_name
      approver_first_and_last_name
      role
      take_on_balance_as_at
      annual_leave_take_on
      educational_leave_take_on
      medical_leave_take_on
      compassionate_leave_take_on
      maternity_leave_take_on
    }.freeze
    
    def perform()
      @bulk_upload = BulkUpload.find(self.upload_id)

      start_upload() && 
        stage_upload() && 
          validate_upload() && 
            apply_upload() && 
              complete_upload()
        
    rescue Exception => error
    
      # any staging, validation and apply 
      # errors will be raised to here
    
      # log out the full error message
      Rails.logger.error error.message
      Rails.logger.error error.backtrace.join("\n")

      # store the failure message
      if Rails.env.production?
        fail_upload(error.message)
      else
        fail_upload("#{error.message}\n#{error.backtrace.join("\n")}")
      end
      
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
            unless (row.fields - VALID_FIELDS) == []
              raise Exception.new("Invalid file header. The following unknown columns found:\n#{(row.fields - VALID_FIELDS)}.\nAborting bulk upload!")
            end
          
          else
          
            bulk_upload_row = @bulk_upload.records.build(row.to_hash)
            bulk_upload_row.line_number = line_number
            
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
    
      true #false
    end

    def apply_upload()
    
      # since approvers referenced may not exist, or are staged, 
      # need to make a number of passes to solve any dependencies
      
      true #false
    end

    def complete_upload()
      @bulk_upload.set_as_processed()
    end

    def fail_upload(error_message)
      @bulk_upload.set_as_failed(error_message)
    end

  end
end

