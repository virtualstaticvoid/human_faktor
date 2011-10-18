class UniqueUserNameForBulkUploadValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    
    return if record.first_name.blank? || record.last_name.blank?
    
    account = record.bulk_upload.account
    
    # checks for duplicates in existing and proposed new employees
    
    if account.employees.where(
          'LOWER(user_name) = LOWER(:user_name)',
          { :user_name => value }
        ).exists? || 

       record.bulk_upload.records.where(
         'LOWER(first_name) = LOWER(:first_name) AND LOWER(last_name) = LOWER(:last_name)',
         { 
          :first_name => record.first_name,
          :last_name => record.last_name
         }
       ).where("id <> #{record.id}").exists?
    
      record.errors[:user_name] << 'has already been taken'
    end
    
  end
end