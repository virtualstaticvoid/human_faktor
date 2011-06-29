require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  test "fixture data valid" do
    employees.each {|record| assert_valid record }
  end

end
