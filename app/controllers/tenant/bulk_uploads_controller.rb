module Tenant
  class BulkUploadsController < AdminController
    
    def new
      @bulk_upload = current_account.bulk_uploads.build()

      respond_to do |format|
        format.html # new.html.erb
      end
    end
    
    def create
      @bulk_upload = current_account.bulk_uploads.build(params[:bulk_upload])
      @bulk_upload.uploaded_by = current_employee  # will always be an admin
    
      respond_to do |format|
        if @bulk_upload.save
          format.html { redirect_to bulk_upload_url(@bulk_upload, :tenant => current_account.subdomain), 
                          :notice => 'Successfully created bulk upload. Please wait while the file is processed.' }
        else
          format.html { render :new }
        end
      end
    end
    
    def show
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
      redirect_to edit_bulk_upload_url(@bulk_upload, :tenant => current_account.subdomain) if @bulk_upload.status_staged?
    end
    
    def edit
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
    end
    
    def update
      @bulk_upload = current_account.bulk_uploads.find(params[:id])

      respond_to do |format|
        if @bulk_upload.set_as_accepted()
          format.html { redirect_to bulk_upload_url(@bulk_upload, :tenant => current_account.subdomain), 
                          :notice => 'Successfully queued bulk upload for import. Please wait while the data is imported.' }
        else
          format.html { render :edit }
        end
      end
    end
    
    def destroy
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
      @bulk_upload.destroy
      
      redirect_to account_url, :notice => 'Successfully deleted bulk upload.'
    end
    
    def template
    end
    
    def download
      @bulk_upload = current_account.bulk_uploads.find(params[:id])
      redirect_to @bulk_upload.authenticated_url()
    end
    
  end
end