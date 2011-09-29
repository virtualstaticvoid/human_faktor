require 'test_helper'

class BulkUploadTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('bulk_uploads') {|key| assert_valid bulk_uploads(key) }
  end

  # NB: internet connection to S3 required 
  test "attach csv file" do
    bulk_upload = bulk_uploads(:one)
    bulk_upload.csv_file = File.new(File.join(FIXTURES_DIR, 'bulk_upload.data'), 'r')
    assert bulk_upload.save
  end

end
