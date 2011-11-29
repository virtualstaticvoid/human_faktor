require 'test_helper'

class TenantAdminTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('tenant_admins') {|key| assert_valid tenant_admins(key) }
  end

end
