require 'test_helper'
require 'functional/tenant/leave_request_controller_base_test'

module Tenant
  class StaffLeaveRequestsControllerTest < ActionController::TestCase
    # all tests inherited from base!
    include Tenant::LeaveRequestsControllerBaseTest
  end
end

