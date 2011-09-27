require 'test_helper'

class <%= class_name %>Test < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('<%= plural_table_name %>') {|key| assert_valid <%= plural_table_name %>(key) }
  end

end
