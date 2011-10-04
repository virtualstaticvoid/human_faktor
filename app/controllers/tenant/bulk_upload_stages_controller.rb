module Tenant
  class BulkUploadStagesController < AdminController

    def index
      @bulk_upload = current_account.bulk_uploads.find(params[:bulk_upload_id])
      @records = @bulk_upload.records.page(params[:page])
    end

  end
end
