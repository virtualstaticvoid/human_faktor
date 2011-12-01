require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  setup do
    sign_in_as :admin
  end

  test "provides partials_path helper" do
    assert_equal 'shared', @controller.send(:partials_path)
  end

  test "provides assigned partials_path value" do
    @controller.send(:"partials_path=", 'test')
    assert_equal 'test', @controller.send(:partials_path)
  end

  test "provides current_account helper" do
    assert @controller.send(:current_account)
  end

  test "provides safe_parse_date helper" do
    assert @controller.send(:safe_parse_date, Date.today.to_s)
  end

  test "provides current_leave_cycle_start_date helper" do
    assert @controller.send(:leave_cycle_start_date, Date.today)
  end

  test "provides current_leave_cycle_end_date helper" do
    assert @controller.send(:leave_cycle_end_date, Date.today)
  end

end
