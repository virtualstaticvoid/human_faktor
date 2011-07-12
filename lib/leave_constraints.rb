module LeaveConstraints

  # constraint name helpers
  Symbol.send(:define_method, :as_constraint) { :"constraint_#{self}" }
  Symbol.send(:define_method, :as_constraint_override) { :"override_#{self}" }

  class Base
  
    @@constraint_types = []
  
    def self.inherited(klass)
      @@constraint_types << klass
    end
    
    def self.evaluate(leave_request)
      constraint_flags = {}
      @@constraint_types.each do |constraint_type|
        constraint_flags[constraint_type.constraint_name] = constraint_type.new().evaluate(leave_request)
      end
      constraint_flags
    end

    def self.constraint_name
      self.name.gsub(/LeaveConstraints::/, '').underscore.to_sym
    end

    def self.constraint_names
      @@constraint_types.map {|constraint_type| constraint_type.constraint_name }
    end
  
    protected 
    
    def evaluate(request)
      throw :error_not_implemented
    end
    
  end
  
  # Number of days notice required
  class ExceedsNumberOfDaysNoticeRequired < Base
  
    def evaluate(request)
      (request.date_from - request.created_at.to_date).to_i < request.leave_type.required_days_notice
    end
    
  end
  
  # Minimum number of days per request
  class ExceedsMinimumNumberOfDaysPerRequest < Base
  
    def evaluate(request)
      request.duration < request.leave_type.min_days_per_single_request 
    end
    
  end
  
  # Maximum number of days per request
  class ExceedsMaximumNumberOfDaysPerRequest < Base
  
    def evaluate(request)
      request.duration > request.leave_type.max_days_per_single_request 
    end
    
  end
  
  # Exceeds leave cycle allowance
  class ExceedsLeaveCycleAllowance < Base
  
    def evaluate(request)
      self.leave_taken(request) > self.leave_allowance(request)
    end

    protected
    
    def leave_taken(request)
      request.leave_type.balance_for(request.employee, request.date_from) + request.duration
    end

    def leave_allowance(request)
      request.leave_type.allowance_for(request.employee, request.date_from)
    end
  
  end
  
  # Exceeds allowed negative leave balance
  class ExceedsNegativeLeaveBalance < ExceedsLeaveCycleAllowance
  
    def evaluate(request)
      super && 
        (self.leave_taken(request) - self.leave_allowance(request)) < request.leave_type.max_negative_balance
    end
    
  end
  
  # Is considered to be unscheduled
  class IsUnscheduled < Base
  
    def evaluate(request)
      !request.leave_type.unscheduled_leave_allowed && 
        request.date_from < request.created_at.to_date
    end

  end
  
  # Is adjacent to a weekend, public holiday, approved leave
  class IsAdjacent < Base
  
    def evaluate(request)
    
      # only applicable if unscheduled
      return false unless request.date_from < request.created_at.to_date
      
      from = (request.date_from - 1) # before
      to = (request.date_to + 1)     # after 
 
      # adjacent to a weekend? (6 = Sat, 0 = Sun)
      adjacent = to.wday == 6 || from.wday == 0
      
      # adjacent to a public holiday
      unless adjacent
        adjacent = request.account.country.calendar_entries.where(:entry_date => [from, to]).any?
      end
        
      # adjacent to pending or approved leave
      unless adjacent
        adjacent = request.employee.leave_requests.active.where(
                     ' ((date_to = :from_date) OR (date_from = :to_date)) AND id <> :id ',
                     { :from_date => from, :to_date => to, :id => request.id }
                   ).any?
      end
      
      adjacent
    end

  end
  
  # Document required, but hasn't been supplied
  class RequiresDocumentation < Base
  
    def evaluate(request)
      request.leave_type.requires_documentation && 
        (request.duration >= request.leave_type.requires_documentation_after) &&
          !request.document_attached?
    end

  end

  # Overlapping leave request (irrespective of leave type)
  class OverlappingRequest < Base
  
    def evaluate(request)
      request.employee.leave_requests.active.where(
        ' (date_from BETWEEN :from_date AND :to_date) OR (date_to BETWEEN :from_date AND :to_date) ', 
        { :from_date => request.date_from, :to_date => request.date_to }
      ).any?
    end

  end
  
  # Exceeds maximum date in the future for a leave request
  class ExceedsMaximumFutureDate < Base

    def evaluate(request)
      # NOTE: implement based on the cycle start date and duration?
      #  and what about rolling window periods for leave type?
      request.date_from > (request.created_at.to_date + request.leave_type.max_days_for_future_dated) 
    end

  end

  # Exceeds maximum date in the past for a leave request
  class ExceedsMaximumBackDate < Base

    def evaluate(request)
      # NOTE: implement based on the cycle start date and duration?
      #  and what about rolling window periods for leave type?
      request.date_from < (request.created_at.to_date - request.leave_type.max_days_for_back_dated)
    end

  end

end
