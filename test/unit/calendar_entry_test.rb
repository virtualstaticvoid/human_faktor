require 'test_helper'

class CalendarEntryTest < ActiveSupport::TestCase

  test "fixture data valid" do
    for_each_fixture ('calendar_entries') {|key| assert_valid calendar_entries(key) }
  end

end
