module Tenant
  class ProcessBulkUpload < Struct.new(:upload_id)
    
    def perform()
      bulk_upload = BulkUpload.find(self.upload_id)

      # TODO:
      #  1. stage
      #  2. validate
      #  3. apply
      #  4. commit & update status


      false # for now...
    end

  end
end

