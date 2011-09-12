require 'date'

class FixEmployeeTakeOnBalanceAsAtDates < ActiveRecord::Migration
  def self.up

    # take_on_balance_as_at is now a required field, so update
    # nil values to either the employment start date, or the record creation date
    
    ActiveRecord::Base.transaction do
    
      # try using the employment start date
      for employee in Employee.where(:take_on_balance_as_at => nil)
        employee.update_attributes!(:take_on_balance_as_at => employee.start_date) if employee.start_date
      end
      
      # all others, use the created_at date
      for employee in Employee.where(:take_on_balance_as_at => nil)
        employee.update_attributes!(:take_on_balance_as_at => employee.created_at.to_date)
      end
      
      # assert!
      throw :take_on_balance_as_at_update_failed unless Employee.where(:take_on_balance_as_at => nil).count() == 0
    
    end
    
  end

  def self.down
    # can't undo this logic...
  end
end
