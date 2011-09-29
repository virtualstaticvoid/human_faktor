require 'test_helper'

class BulkUploadStageTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('bulk_upload_stages') {|key| assert_valid bulk_upload_stages(key) }
  end

end
