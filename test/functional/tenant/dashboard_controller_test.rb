require 'test_helper'

module Tenant
  class DashboardControllerTest < ActionController::TestCase

    test "should redirect to home_sign_in" do
      get :index, :tenant => 'non-existent'
      assert_redirected_to home_sign_in_url
    end

    test "should redirect to employee_sign_in" do
      get :index, :tenant => @account.subdomain
      assert_redirected_to new_employee_session_url(:tenant => @account.subdomain)
    end

    Employee::ROLES.each do |role|

      test "should get index as #{role}" do
        sign_in_as role
        get :index, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get welcome as #{role}" do
        sign_in_as role
        get :welcome, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get balance as #{role}" do
        sign_in_as role
        get :balance, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get calendar as #{role}" do
        sign_in_as role
        get :calendar, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get help as #{role}" do
        sign_in_as role
        get :help, :tenant => @account.subdomain
        assert_response :success
      end

      # NOTE: add additional actions here

    end

    test "should redirect to balance if employee requests staff balance" do
      sign_in_as :employee
      get :staff_balance, :tenant => @account.subdomain
      assert_redirected_to balance_url(:tenant => @account.subdomain)
    end

    test "should redirect to calendar if employee requests staff calendar" do
      sign_in_as :employee
      get :staff_calendar, :tenant => @account.subdomain
      assert_redirected_to calendar_url(:tenant => @account.subdomain)
    end

    [:approver, :employee].each do |role|

      test "should redirect to dashboard if #{role} requests heatmap analysis" do
        sign_in_as role
        get :heatmap, :tenant => @account.subdomain
        assert_redirected_to dashboard_url(:tenant => @account.subdomain)
      end

    end

    test "should redirect to dashboard if employee requests staff summary" do
      sign_in_as :employee
      get :staff_summary, :tenant => @account.subdomain
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end

    test "should get staff balance for approver" do
      sign_in_as :approver
      get :staff_balance, :tenant => @account.subdomain
      assert_response :success
    end

    test "should get staff balance filtered by location" do
      sign_in_as :approver
      get :staff_balance, :tenant => @account.subdomain, :staff_balance_enquiry => { 
                                                            :filter_by => 'location', 
                                                            :location_id => @account.locations.first.id 
                                                          }
      assert_response :success
    end

    test "should get staff balance filtered by department" do
      sign_in_as :approver
      get :staff_balance, :tenant => @account.subdomain, :staff_balance_enquiry => { 
                                                            :filter_by => 'department',
                                                            :department_id => @account.departments.first.id 
                                                          }
      assert_response :success
    end

    test "should get staff calendar for approver" do
      sign_in_as :approver
      get :staff_calendar, :tenant => @account.subdomain
      assert_response :success
    end
  
    test "should get staff calendar filtered by location" do
      sign_in_as :approver
      get :staff_calendar, :tenant => @account.subdomain, :staff_calendar_enquiry => { 
                                                            :filter_by => 'location', 
                                                            :location_id => @account.locations.first.id 
                                                          }
      assert_response :success
    end

    test "should get staff calendar filtered by department" do
      sign_in_as :approver
      get :staff_calendar, :tenant => @account.subdomain, :staff_calendar_enquiry => { 
                                                            :filter_by => 'department', 
                                                            :department_id => @account.departments.first.id 
                                                          }
      assert_response :success
    end

    test "should get staff calendar filtered by employee" do
      sign_in_as :approver
      get :staff_calendar, :tenant => @account.subdomain, :staff_calendar_enquiry => { 
                                                            :filter_by => 'employee', 
                                                            :employee_id => employees(:approver).to_param 
                                                          }
      assert_response :success
    end

    [:admin, :manager, :approver].each do |role|

      test "should get staff summary for #{role}" do
        sign_in_as role
        get :staff_summary, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get staff summary for #{role} filtered by date from" do
        sign_in_as role
        get :staff_summary, :tenant => @account.subdomain, :staff_summary_enquiry => { 
                                                              :date_from => Date.new(2011, 1, 1) 
                                                            }
        assert_response :success
      end

      test "should get staff summary for #{role} filtered by date to" do
        sign_in_as role
        get :staff_summary, :tenant => @account.subdomain, :staff_summary_enquiry => { 
                                                              :date_to => Date.new(2011, 12, 31) 
                                                            }
        assert_response :success
      end

      test "should get staff summary for #{role} filtered by date from and to" do
        sign_in_as role
        get :staff_summary, :tenant => @account.subdomain, :staff_summary_enquiry => { 
                                                              :date_from => Date.new(2011, 1, 1),
                                                              :date_to => Date.new(2011, 12, 31) 
                                                            }
        assert_response :success
      end

      test "should get staff summary for #{role} filtered by location" do
        sign_in_as role
        get :staff_summary, :tenant => @account.subdomain, :staff_summary_enquiry => { 
                                                              :filter_by => 'location', 
                                                              :location_id => @account.locations.first.id 
                                                            }
        assert_response :success
      end

      test "should get staff summary for #{role} filtered by department" do
        sign_in_as role
        get :staff_summary, :tenant => @account.subdomain, :staff_summary_enquiry => { 
                                                              :filter_by => 'location', 
                                                              :location_id => @account.locations.first.id 
                                                            }
        assert_response :success
      end

      test "should get staff summary for #{role} filtered by employee" do
        sign_in_as role
        get :staff_summary, :tenant => @account.subdomain, :staff_calendar_enquiry => { 
                                                              :filter_by => 'employee', 
                                                              :employee_id => employees(:employee).to_param 
                                                            }
        assert_response :success
      end

    end

    [:manager, :admin].each do |role|

      test "should get staff balance for #{role}" do
        sign_in_as role
        get :staff_balance, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get staff calendar for #{role}" do
        sign_in_as role
        get :staff_calendar, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get heatmap analysis for #{role}" do
        sign_in_as role
        get :heatmap, :tenant => @account.subdomain
        assert_response :success
      end

      test "should get heatmap analysis for #{role} filtered by location" do
        sign_in_as role
        get :heatmap, :tenant => @account.subdomain, :heat_map_enquiry => { 
                                                        :filter_by => 'location', 
                                                        :location_id => @account.locations.first.id 
                                                      }
        assert_response :success
      end

      test "should get heatmap analysis for #{role} filtered by department" do
        sign_in_as role
        get :heatmap, :tenant => @account.subdomain, :heat_map_enquiry => { 
                                                        :filter_by => 'location', 
                                                        :location_id => @account.locations.first.id 
                                                      }
        assert_response :success
      end

    end

    test "should get balance" do
      sign_in_as :employee
      get :balance, :tenant => @account.subdomain
      assert_response :success
    end

    test "should get balance for self" do
      sign_in_as :employee
      get :balance, :tenant => @account.subdomain, :employee => employees(:employee).to_param
      assert_response :success
    end

    test "cannot get balance for non-subordinate employee" do
      sign_in_as :employee
      get :balance, :tenant => @account.subdomain, :employee => employees(:employee1).to_param
      assert_redirected_to dashboard_url(:tenant => @account.subdomain)
    end

    test "should get balance for subordinate employee" do
      sign_in_as :admin
      get :balance, :tenant => @account.subdomain, :employee => employees(:employee).to_param
      assert_response :success
    end

  end
end
