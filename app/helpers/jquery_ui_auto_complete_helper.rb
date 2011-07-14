module JqueryUiAutoCompleteHelper
  include ActionView::Helpers::FormTagHelper

  ##
  # block yields resolved value
  # 
  #  Example block: {|item_id| Item.find(item_id) }
  #
  def auto_complete(method, options={}, &block)

    sanitized_object_name ||= @object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    sanitized_method_name ||= method.to_s.sub(/\?$/,"")
    has_error = @object.errors[method].present?

    value = @object.send(method)
    value_resolved = (block_given? && block.arity == 1) ? 
      block.call(value) :
      value.to_s
    
    html = ""
    html << "<div class=\"field_with_errors\">" if has_error
    html << hidden_field_tag("#{@object_name.to_s}[#{method.to_s}]", value)
    html << text_field_tag("#{@object_name.to_s}_autocomplete[#{method.to_s}]", value_resolved, options)
    html << "<script type=\"text/javascript\">"
    html << "  $(function() {"
    html << "    $('##{sanitized_object_name}_autocomplete_#{sanitized_method_name}').autocomplete({"
    html << "         source: \"#{options[:source]}\" "
    
    # write out autocomplete options
    # see http://jqueryui.com/demos/autocomplete/#options for available list
    if options[:options].is_a?(Hash)
      options[:options].each do |key, value|
        html << ", #{key}: #{value}"
      end
    end
    
    html << "         , select: function(event, ui) {"
    html << "           $('##{sanitized_object_name}_#{sanitized_method_name}').val(ui.item.id);"
    html << "           $('##{sanitized_object_name}_#{sanitized_method_name}').change();"
    html << "         },"
    html << "         change: function(event, ui) {"
    html << "           if (ui.item == null) {"
    html << "             $('##{sanitized_object_name}_#{sanitized_method_name}').val(null);"
    html << "           }"
    html << "           $('##{sanitized_object_name}_#{sanitized_method_name}').change();"
    html << "         }"
    html << "    });"
    html << "  });"
    html << "</script>"
    html << "</div>" if has_error
    
    html.html_safe
    
  end
  
end

ActionView::Helpers::FormBuilder.send(:include, JqueryUiAutoCompleteHelper)

