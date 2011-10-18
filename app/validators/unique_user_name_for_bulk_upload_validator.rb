class UniqueUserNameForBulkUploadValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    
    return if record.first_name.blank? || record.last_name.blank?
    
    account = record.bulk_upload.account
    
    # checks for duplicates in existing and proposed new employees
    
    if account.employees.where(
          'LOWER(user_name) = :user_name',
          { :user_name => value.downcase }
        ).exists? || 

       record.bulk_upload.records.where(
         'LOWER(first_name) = :first_name AND LOWER(last_name) = :last_name',
         { 
          :first_name => record.first_name.downcase,
          :last_name => record.last_name.downcase 
         }
       ).where("id <> #{record.id}").exists?
    
      record.errors[:user_name] << 'has already been taken'
    end
    
  end
end