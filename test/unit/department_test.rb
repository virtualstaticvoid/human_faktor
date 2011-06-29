require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase

  test "fixture data valid" do
    departments.each {|record| assert_valid record }
  end

end
