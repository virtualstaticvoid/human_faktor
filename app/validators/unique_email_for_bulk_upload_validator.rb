class UniqueEmailForBulkUploadValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    account = record.bulk_upload.account
    record.errors[:email] << 'must be unique' if account.employees.where(:email => value).count() > 0
    
  end
end
