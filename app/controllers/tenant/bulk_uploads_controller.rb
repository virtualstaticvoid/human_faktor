module Tenant
  class BulkUploadsController < AdminController
    
    def new
      @bulk_upload = current_account.bulk_uploads.build()
    end
    
    def create
      @bulk_upload = current_account.bulk_uploads.build(params[:bulk_upload])
    
      if @bulk_upload.save
        redirect_to account_url, :notice => 'Successfully created bulk upload. Processing will begin shortly. You will receive an email when the data has been imported.'
      else
        render :new
      end
    end
    
    def show
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
    end
    
    def destroy
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
      @bulk_upload.destroy
      
      redirect_to account_url, :notice => 'Successfully deleted bulk upload.'
    end
    
  end
end
