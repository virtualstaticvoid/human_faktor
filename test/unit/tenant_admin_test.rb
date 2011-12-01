require 'test_helper'

class TenantAdminTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('tenant_admins') do |key| 
      tenant_admin = tenant_admins(key)
      tenant_admin.password = 'sekret'
      tenant_admin.password_confirmation = 'sekret'
      assert_valid tenant_admin 
    end
  end

end
