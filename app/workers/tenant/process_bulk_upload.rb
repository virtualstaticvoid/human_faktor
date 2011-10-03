require 'aws/s3'
require 'csv'

module Tenant
  class ProcessBulkUpload < Struct.new(:upload_id)
  
    VALID_FIELDS = [      
      :reference,
      :title,
      :first_name,
      :middle_name,
      :last_name,
      :gender,
      :email,
      :telephone,
      :mobile,
      :designation,
      :start_date,
      :location_name,
      :department_name,
      :approver_first_and_last_name,
      :role,
      :take_on_balance_as_at,
      :annual_leave_take_on,
      :educational_leave_take_on,
      :medical_leave_take_on,
      :compassionate_leave_take_on,
      :maternity_leave_take_on
    ].freeze
    
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
      fail_upload(error.message)
      
      false
    end
    
    private
    
    def start_upload()
      @bulk_upload.set_as_processing
    end
    
    def stage_upload()
    
      # import the file as is into the bulk upload stage model

      options = { 
        :header => :first_row, 
        :return_headers => false,
        :skip_blanks => true
      }

puts @bulk_upload.authenticated_url      
binding.pry if Rails.env.development?
      
      CSV.foreach(@bulk_upload.authenticated_url, *options) do |row|
        # use row here...
        
        puts row.inspect
        
      end

binding.pry if Rails.env.development?
      
      #raise Exception.new("Failed to upload")    
    
      true #false
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

