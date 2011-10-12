require 'test_helper'

class LeaveRequestTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('leave_requests') {|key| assert_valid leave_requests(key), key }
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

  test "should not allow an overlapping leave request to be created (including unconfirmed leave)" do
    leave_request = leave_requests(:annual)
    assert leave_request.status_new?
    
    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => leave_request.date_from + 1,
      :date_to => leave_request.date_to - 1,
      :comment => 'Test'
    ).valid?

  end
  
  test "should not allow an overlapping leave request to be created" do
    leave_request = leave_requests(:annual)
    assert leave_request.confirm!
    assert leave_request.status_pending?
    
    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => leave_request.date_from + 1,
      :date_to => leave_request.date_to - 1,
      :comment => 'Test'
    ).valid?

    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => leave_request.date_from,
      :date_to => leave_request.date_to,
      :comment => 'Test'
    ).valid?
    
    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => leave_request.date_from + 1,
      :date_to => leave_request.date_to - 1,
      :comment => 'Test'
    ).valid?

    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => leave_request.date_from - 1,
      :date_to => leave_request.date_to - 1,
      :comment => 'Test'
    ).valid?

    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => leave_request.date_from - 1,
      :date_to => leave_request.date_to + 1,
      :comment => 'Test'
    ).valid?

  end
  
  test "cannot apply for leave prior to start date" do
    leave_request = leave_requests(:annual)
    
    employee = leave_request.employee
    employee.update_attributes!(:start_date => Date.today)

    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => Date.today - 1,
      :date_to => Date.today,
      :comment => 'Test'
    ).valid?
    
  end

  test "cannot apply for leave prior to take on balance as at date" do
    leave_request = leave_requests(:annual)
    
    employee = leave_request.employee
    employee.update_attributes!(:take_on_balance_as_at => Date.today)

    assert !LeaveRequest.new(
      :account_id => leave_request.account_id,
      :leave_type_id => leave_request.leave_type_id,
      :employee_id => leave_request.employee_id,
      :approver_id => leave_request.approver_id,
      :date_from => Date.today - 1,
      :date_to => Date.today,
      :comment => 'Test'
    ).valid?
    
  end

end
