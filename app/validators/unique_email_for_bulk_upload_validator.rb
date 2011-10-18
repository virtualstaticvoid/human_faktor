class UniqueEmailForBulkUploadValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    account = record.bulk_upload.account
    record.errors[:email] << 'must be unique' if account.employees.where(
      "LOWER(email) = LOWER(:email)",
      { :email => value }
    ).exists?
    
  end
end