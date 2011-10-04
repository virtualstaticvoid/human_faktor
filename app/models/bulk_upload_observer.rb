class BulkUploadObserver < ActiveRecord::Observer

  def after_create(bulk_upload)
    WorkQueue.enqueue(Tenant::StageBulkUpload, bulk_upload.id) if bulk_upload.status_pending?
  end

  def after_update(bulk_upload)
    WorkQueue.enqueue(Tenant::ProcessBulkUpload, bulk_upload.id) if bulk_upload.status_accepted?
  end

end

