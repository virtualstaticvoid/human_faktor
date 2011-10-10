class UniqueUserNameForBulkUploadValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    
    account = record.bulk_upload.account
    record.errors[:email] << 'must be unique' if account.employees.where(:user_name => value).count() > 0
    
  end
end
