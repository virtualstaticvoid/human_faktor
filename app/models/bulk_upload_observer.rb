class BulkUploadObserver < ActiveRecord::Observer

  def after_create(bulk_upload)
    WorkQueue.enqueue(Tenant::StageBulkUpload, bulk_upload.id)
  end

  def after_update(bulk_upload)
    # only process if the status changed and is now set to accepted
    WorkQueue.enqueue(Tenant::ProcessBulkUpload, bulk_upload.id) if bulk_upload.changed.any? {|field| field == 'status' } && bulk_upload.status_accepted?
  end

end

