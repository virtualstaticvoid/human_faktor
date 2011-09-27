require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('departments') {|key| assert_valid departments(key) }
  end

end
