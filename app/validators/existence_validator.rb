class ExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_nil] == true && value.nil?

    # HACK: convert to :*_id version
    #  this may be incorrect sometimes... 
    #  assuming that the belongs_to relation name and field line up...
    #  
    #  e.g. Given the following employee model
    #
    #       class Employee < ActiveModel::Base
    #         belongs_to :account
    #         validates_existence_of :account
    #       end
    #
    #  It is assumed that the employee has an `account_id` attribute
    #
    attribute_validated = :"#{attribute.to_s}_id"
    
    if value.nil?
      record.errors[attribute_validated] << "can't be blank"
    else
      assoc = record.class.send(:reflect_on_association, attribute)
      unless assoc
        puts "ERROR: unable to reflect #{record} model for association on #{attribute} attribute."
        puts " this is probably because there is no `belongs_to` declared for this attribute."
      end
      record.errors[attribute_validated] << 'does not exist' unless assoc.klass.exists?(value)
    end
  end
end

