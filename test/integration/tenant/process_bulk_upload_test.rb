require 'test_helper'

module Tenant

  class ProcessBulkUploadTest < ActionDispatch::IntegrationTest
    fixtures :all

    test "should perform work" do
      
      bulk_upload = bulk_uploads(:one)
      bulk_upload.csv = File.new(File.join(FIXTURES_DIR, 'bulk_upload.data'), 'r')
      assert bulk_upload.save
    
      result = if StageBulkUpload.new(bulk_upload.id).perform()
        ProcessBulkUpload.new(bulk_upload.id).perform()
      end
      
      bulk_upload.reload
      #puts bulk_upload.messages
      
      assert result
      
    end

  end
  
end
