module Tenant
  class DataFeedsController < TenantController

    def calendar_entries
      from_date = Time.at(params[:start].to_i).to_date
      to_date = Time.at(params[:end].to_i).to_date

      @calendar_entries = current_account.country.calendar_entries.where(
        ' entry_date BETWEEN :from_date AND :to_date ',
        { :from_date => from_date, :to_date => to_date } 
      )
      
      respond_to do |format|
        format.json # calendar_entries.json.erb
      end
    end
    
    def leave_requests
      from_date = Time.at(params[:start].to_i).to_date
      to_date = Time.at(params[:end].to_i).to_date

      @leave_requests = current_employee.leave_requests.active.where(
        ' (date_from BETWEEN :from_date AND :to_date ) OR ( date_to BETWEEN :from_date AND :to_date ) ',
        { :from_date => from_date, :to_date => to_date } 
      )
    
      respond_to do |format|
        format.json # leave_requests.json.erb
      end
    end

  end
end