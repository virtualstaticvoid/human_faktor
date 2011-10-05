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
      logger.error error.message
      logger.error error.backtrace.join("\n")

      # store the failure message
      fail_upload(error)

      false
    end

    private

    def start_processing()
      logger.info("#{@bulk_upload.id}: Started processing bulk upload.")
      @bulk_upload.set_as_processing
    end
    
    def apply_upload()
      logger.info("#{@bulk_upload.id}: Processing bulk upload.")

      # TODO: load according to load sequence...
      
      true
    end
  
    def complete_processing()
      logger.info("#{@bulk_upload.id}: Completed processing bulk upload.")
      @bulk_upload.set_as_processed()
    end

    def fail_upload(error)
      logger.info("#{@bulk_upload.id}: Failed to process bulk upload.")
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

