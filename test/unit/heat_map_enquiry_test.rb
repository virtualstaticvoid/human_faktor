require 'test_helper'
require 'heat_map_enquiry'

class HeatMapEnquiryTest < ActiveSupport::TestCase

  setup do
    @account = accounts(DEFAULT_ACCOUNT)
    @criteria = HeatMapEnquiry.new(@account, employees(:admin)).tap do |c|
      c.date_from = Date.new(2010, 1, 1)
      c.date_to = Date.new(2011, 12, 31)
    end
  end

  HeatMapEnquiry::Base.enquiry_types.each do |enquiry_type| 

    test "should provide json for #{enquiry_type}" do
      @criteria.enquiry = enquiry_type.to_s
      assert @criteria.json
    end
  
  end
  
  # TODO: test each enquiry individually to ensure that the content is correct

  test "HeatMapEnquiry::UnscheduledLeaveAdjacentToWeekend" do
    @criteria.enquiry = 'HeatMapEnquiry::UnscheduledLeaveAdjacentToWeekend'
    json = @criteria.json
    #puts json
  end

end
