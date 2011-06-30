class ExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_nil] == true && value.nil?
    assoc = record.class.send(:reflect_on_association, attribute)
    
    unless assoc
      puts "ERROR: unable to reflect #{record} model for association on #{attribute} attribute."
      puts " this is probably because there is no `belongs_to` declared for this attribute."
    end
    
    record.errors[attribute] << 'does not exist' unless assoc.klass.exists?(value)
  end
end

