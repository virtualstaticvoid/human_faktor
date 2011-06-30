require 'test_helper'

class LeaveRequestTest < ActiveSupport::TestCase

  test "fixture data valid" do
    leave_requests.each {|record| assert_valid record }
  end

  # NB: internet connection to S3 required 
  test "attach document" do
    leave_request = leave_requests(:annual)
    leave_request.document = File.new(File.join(FIXTURES_DIR, 'document.txt'), 'r')
    assert leave_request.save
  end

end
