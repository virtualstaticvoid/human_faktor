module Tenant
  class ProcessBulkUpload < Struct.new(:upload_id)
  
    def perform()
      @bulk_upload = BulkUpload.find(self.upload_id)

      # TODO: apply changes to employee table

    end

  end
end

