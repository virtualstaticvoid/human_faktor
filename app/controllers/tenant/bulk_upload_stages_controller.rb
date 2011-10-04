module Tenant
  class BulkUploadStagesController < AdminController

    def index
      @bulk_upload = current_account.bulk_uploads.find(params[:bulk_upload_id])
      case params[:status]
        when 'valid'
          @records = @bulk_upload.records.where(:selected => true).page(params[:page])
        when 'errors'
          @records = @bulk_upload.records.where(:selected => false).page(params[:page])
        else
          @records = @bulk_upload.records.page(params[:page])
      end
    end

  end
end
