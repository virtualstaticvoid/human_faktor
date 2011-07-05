require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  test "fixture data valid" do
    employees.each {|record| assert_valid record }
  end
  
  # NB: internet connection to S3 required 
  test "attach avatar" do
    employee = employees(:admin)
    employee.avatar = File.new(File.join(FIXTURES_DIR, 'logo.png'), 'r')
    assert employee.save
  end

  test "check employee with admin role" do
    employee = employees(:admin)
    assert_equal employee.role_sym, :admin
    assert !employee.is_employee?
    assert !employee.is_approver?
    assert !employee.is_manager?
    assert employee.is_admin?
  end

  test "check employee with manager role" do
    employee = employees(:manager)
    assert_equal employee.role_sym, :manager
    assert !employee.is_employee?
    assert !employee.is_approver?
    assert employee.is_manager?
    assert !employee.is_admin?
  end

  test "check employee with approver role" do
    employee = employees(:approver)
    assert_equal employee.role_sym, :approver
    assert !employee.is_employee?
    assert employee.is_approver?
    assert !employee.is_manager?
    assert !employee.is_admin?
  end

  test "check employee with employee role" do
    employee = employees(:employee)
    assert_equal employee.role_sym, :employee
    assert employee.is_employee?
    assert !employee.is_approver?
    assert !employee.is_manager?
    assert !employee.is_admin?
  end

  Employee::ROLES.each do |role|

    test "check can_create_leave_for_other_employees? for #{role}" do
      employee = employees(role)
      assert_equal [:admin, :manager].include?(role), employee.can_create_leave_for_other_employees?
    end

    test "check can_approve_decline_or_cancel_leave? for #{role}" do
      employee = employees(role)
      assert_equal [:admin, :manager, :approver].include?(role), employee.can_approve_decline_or_cancel_leave?
    end
  
  end

  test "can choose approver when approver inactive" do
    employee = employees(:employee)
    assert !employee.can_choose_own_approver?
    employee.approver.active = false
    assert employee.can_choose_own_approver?
  end

  test "can choose approver when approver nil" do
    employee = employees(:employee)
    assert !employee.can_choose_own_approver?
    employee.approver = nil
    assert employee.can_choose_own_approver?
  end

  test "check staff" do
    employees.each do |employee|
      assert_not_nil employee.staff
    end
  end

  #
  # Hierarchy:
  #
  #   admin 1
  #    + manager 1
  #    |  + approver 1
  #    |  |  + approver 2
  #    |  |  | - employee 1
  #    |  |  | - employee 2
  #    |  |  + employee 3
  #    |  + manager 2
  #    |     | - employee 4
  #    + manager 3
  #       | - employee 5
  #
  #
  
  test "hierarchy tests" do
    pending
  end

end
