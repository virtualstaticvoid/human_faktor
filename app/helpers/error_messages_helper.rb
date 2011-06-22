module ErrorMessagesHelper

  # Render error messages for the given objects. 
  # The :message option is allowed.
  def error_messages_for(*objects)
    options = objects.extract_options!
    options[:message] ||= I18n.t(:"activerecord.errors.message", :default => "One or more fields need to be supplied or corrected.")
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      content_tag(:div, :class => "error_messages box_radius") do
        list_items = messages.map { |msg| content_tag(:li, msg.html_safe) }
        content_tag(:p, options[:message].html_safe) + content_tag(:ul, list_items.join.html_safe)
      end
    end
  end

end

