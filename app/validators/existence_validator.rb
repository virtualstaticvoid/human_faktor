class ExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_nil] == true && value.nil?
    assoc = record.class.send(:reflect_on_association, attribute)
    record.errors[attribute] << 'does not exist' unless assoc.klass.exists?(value)
  end
end

