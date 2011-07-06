module Tenant
  class LocationsController < AdminController
  
    def index
      @locations = current_account.locations.page(params[:page])
    end
    
    def new
      @location = Location.new

      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    def create
      @location = current_account.locations.build(params[:location])

      respond_to do |format|
        if @location.save
          format.html { redirect_to(locations_url(:tenant => current_account.subdomain), :notice => 'Location was successfully created.') }
        else
          format.html { render :action => "new" }
        end
      end
    end
    
    def edit
      @location = current_account.locations.find(params[:id])
    end
    
    def update
      @location = current_account.locations.find(params[:id])

      respond_to do |format|
        if @location.update_attributes(params[:location])
          format.html { redirect_to(locations_url(:tenant => current_account.subdomain), :notice => 'Location was successfully updated.') }
        else
          format.html { render :action => "edit" }
        end
      end
    end
    
    def destroy
      @location = current_account.locations.find(params[:id])
      @location.destroy
    
      respond_to do |format|
        format.html { redirect_to(locations_url(:tenant => current_account.subdomain), :notice => 'Location was successfully deleted.') }
        format.js   {}
      end
    end
  
  end
end
