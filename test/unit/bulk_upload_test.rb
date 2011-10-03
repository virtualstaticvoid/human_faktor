require 'test_helper'

class BulkUploadTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('bulk_uploads') {|key| assert_valid bulk_uploads(key) }
  end

  # NB: internet connection to S3 required 
  test "attach csv file" do
    bulk_upload = bulk_uploads(:one)
    bulk_upload.csv = File.new(File.join(FIXTURES_DIR, 'bulk_upload.data'), 'r')
    assert bulk_upload.save
  end
  
  test "to_s should return the date and file name of the upload" do
    bulk_upload = bulk_uploads(:one)
    bulk_upload.csv = File.new(File.join(FIXTURES_DIR, 'bulk_upload.data'), 'r')
    assert bulk_upload.save
    assert_equal "#{bulk_upload.created_at.strftime('%Y-%m-%d %H:%M')} - #{bulk_upload.csv.original_filename}", bulk_upload.to_s
  end

end
