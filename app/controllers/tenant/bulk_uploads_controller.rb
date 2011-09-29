module Tenant
  class BulkUploadsController < AdminController
    
    def index
      @bulk_uploads = current_account.bulk_uploads.page(params[:page])
    end
    
    def new
      @bulk_upload = current_account.bulk_uploads.build()

      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    def create
      @bulk_upload = current_account.bulk_uploads.build(params[:bulk_upload])
    
      respond_to do |format|
        if @bulk_upload.save
          format.html { redirect_to account_url, :notice => 'Successfully created bulk upload. Processing will begin shortly. You will receive an email when the data has been imported.' }
        else
          format.html { render :new }
        end
      end
    end
    
    def show
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
    end
    
    def destroy
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
      @bulk_upload.destroy
      
      respond_to do |format|
        format.html { redirect_to account_url, :notice => 'Successfully deleted bulk upload.' }
        format.js   {}
      end
    end
    
  end
end
