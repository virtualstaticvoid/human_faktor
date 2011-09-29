require 'test_helper'

module Tenant

  class ProcessBulkUploadTest < ActionDispatch::IntegrationTest
    fixtures :all

    test "should perform work" do
      
      bulk_upload = bulk_uploads(:one)
      bulk_upload.csv_file = File.new(File.join(FIXTURES_DIR, 'bulk_upload.data'), 'r')
      assert bulk_upload.save
    
      assert ProcessBulkUpload.new(bulk_upload.id).perform()
    end

  end
  
end
