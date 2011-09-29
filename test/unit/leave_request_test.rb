require 'test_helper'

class LeaveRequestTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('leave_requests') {|key| assert_valid leave_requests(key) }
  end

  # NB: internet connection to S3 required 
  test "attach document" do
    leave_request = leave_requests(:annual)
    leave_request.document = File.new(File.join(FIXTURES_DIR, 'document.txt'), 'r')
    assert leave_request.save
  end
  
  test "should supply authenticated url for attached document" do
    leave_request = leave_requests(:annual)
    leave_request.document = File.new(File.join(FIXTURES_DIR, 'document.txt'), 'r')
    assert !leave_request.document_authenticated_url.blank?
  end
  
  test "should automatically approve if no approval required" do
    leave_type = leave_types(:annual)
    leave_type.approval_required = false
    leave_type.save!
    
    leave = LeaveRequest.new(
      :account_id => accounts(:one).id,
      :leave_type_id => leave_type.id,
      :employee_id => employees(:employee).id,
      :approver_id => employees(:admin).id,
      :date_from => Date.today + 2,
      :date_to => Date.today + 12,
      :comment => 'Test'
    )
    assert leave.confirm!(leave.employee)
    assert leave.status_approved?
  end

end
