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

    value = @object.send(method)
    value_resolved = (block_given? && block.arity == 1) ? 
      block.call(value) :
      value.to_s
    
    # insert defaults
    options[:min_length] = '2' unless options[:min_length]

    html = ""
    html << hidden_field_tag("#{@object_name.to_s}[#{method.to_s}]", value) + "\n"
    html << text_field_tag("#{@object_name.to_s}_autocomplete[#{method.to_s}]", value_resolved, options) + "\n"
    html << "<script type=\"text/javascript\">" + "\n"
    html << "  $(function() {" + "\n"
    html << "    $('##{sanitized_object_name}_autocomplete_#{sanitized_method_name}').autocomplete({" + "\n"
    html << "         source: \"#{options[:source]}\", " + "\n"
    html << "         minLength: #{options[:min_length]}, " + "\n"
    html << "         select: function(event, ui) {" + "\n"
    html << "           $('##{sanitized_object_name}_#{sanitized_method_name}').val(ui.item.id);" + "\n"
    html << "         }" + "\n"
    html << "    });" + "\n"
    html << "  });" + "\n"
    html << "</script>" + "\n"
    
    html.html_safe
    
  end
  
end

ActionView::Helpers::FormBuilder.send(:include, JqueryUiAutoCompleteHelper)

