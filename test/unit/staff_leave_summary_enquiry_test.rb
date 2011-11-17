require 'test_helper'

class StaffLeaveSummaryEnquiryTest < ActiveSupport::TestCase

  setup do
    @account = accounts(DEFAULT_ACCOUNT)
    @employee = @account.employees.first
    @enquiry = StaffLeaveSummaryEnquiry.new(@account, @employee)
    @enquiry.date_from = Date.new(2011, 1, 1)
    @enquiry.date_to = Date.new(2011, 12, 31)
  end

  test "should get employees when not filtered" do
    assert @enquiry.employees
  end

  test "should get employees when filtered by location" do
    @enquiry.filter_by = 'location'
    @enquiry.location_id = @account.locations.first.id
    assert @enquiry.employees
  end

  test "should get employees when filtered by department" do
    @enquiry.filter_by = 'department'
    @enquiry.department_id = @account.departments.first.id
    assert @enquiry.employees
  end

  test "should get employees when filtered by employee" do
    @enquiry.filter_by = 'employee'
    @enquiry.employee_id = @account.employees.first.identifier
    assert @enquiry.employees
  end

  test "should provide summary_for by employee" do
    assert @enquery.summary_for(@employee)
  end

end
