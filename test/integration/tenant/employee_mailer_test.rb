require 'test_helper'

module Tenant

  class EmployeeMailerTest < ActionDispatch::IntegrationTest
    fixtures :all

    test "should perform work" do
      employee = employees(:employee)
      
      EmployeeMailer.new(employee.id).perform()
      
      # TODO: assert that an email was sent
      assert !ActionMailer::Base.deliveries.empty?
      
    end

  end
  
end
