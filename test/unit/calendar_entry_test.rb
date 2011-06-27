require 'test_helper'

class CalendarEntryTest < ActiveSupport::TestCase

  test "fixture data valid" do
    calendar_entries.each {|record| assert_valid record }
  end

end
