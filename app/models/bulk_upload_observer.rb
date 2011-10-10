class BulkUploadObserver < ActiveRecord::Observer

  def after_create(bulk_upload)
    puts ">>> BulkUploadObserver#after_create (bulk_upload.status_pending? => #{bulk_upload.status_pending?})"
    WorkQueue.enqueue(Tenant::StageBulkUpload, bulk_upload.id) if bulk_upload.status_pending?
  end

  def after_update(bulk_upload)
    puts ">>> BulkUploadObserver#after_update (bulk_upload.status_accepted? => #{bulk_upload.status_accepted?})"
    WorkQueue.enqueue(Tenant::ProcessBulkUpload, bulk_upload.id) if bulk_upload.status_accepted?
  end

end

