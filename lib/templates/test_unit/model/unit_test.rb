require 'test_helper'

class <%= class_name %>Test < ActiveSupport::TestCase

  test "fixture data valid" do
    <%= plural_table_name %>.each {|record| assert_valid record }
  end

end
