require 'aws/s3'
require 'csv'

module Tenant
  class ProcessBulkUpload < Struct.new(:upload_id)
    
    def perform()
      @bulk_upload = BulkUpload.find(self.upload_id)

      stage_upload() && validate_upload() && apply_upload() && complete_upload()
        
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
    
    def stage_upload()
    
      # import the file as is into the bulk upload stage model
      
      #binding.pry
      
      options = { 
        :header => :first_row, 
        :return_headers => false,
        :skip_blanks => true
      }
      
      CSV.foreach(@bulk_upload.authenticated_url, 'r', *options) do |row|
        # use row here...
        
        puts row.inspect
        
      end    
    
      false
    end

    def validate_upload()
    
      # validate each row, save the error message per row?
      # and raise an exception at the end to indicate failure
      # fault tolerant? skip problem rows?
    
      false
    end

    def apply_upload()
    
      # since approvers referenced may not exist, or are staged, 
      # need to make a number of passes to solve any dependencies
      
      false
    end

    def complete_upload()
      @bulk_upload.set_as_processed()
    end

    def fail_upload(error_message)
      @bulk_upload.set_as_failed(error_message)
    end

  end
end

