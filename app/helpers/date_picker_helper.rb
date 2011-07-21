module DatePickerHelper
  include ActionView::Helpers::FormTagHelper
  
  def date_picker(method, options={})
  
    date_picker_options = options.delete(:options) || {}

    sanitized_object_name ||= @object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    sanitized_method_name ||= method.to_s.sub(/\?$/,"")

    value = @object.send(method)
    has_error = @object.errors[method].present?
    
    options[:style] = "width: 158px;" unless options[:style]

    html = ""
    html << "<div class=\"field_with_errors\">" if has_error
    html << text_field_tag("#{@object_name.to_s}[#{method.to_s}]", value, options)
    html << "<script type=\"text/javascript\">"
    html << "  $(function() {"
    html << "    $('##{sanitized_object_name}_#{sanitized_method_name}').datepicker({"
    html << "         dateFormat: 'yy-mm-dd', "
    html << "         showOtherMonths: true, "
    html << "         selectOtherMonths: true, "
    html << "         constrainInput: true, "
    html << "         changeYear: true, "
    html << "         gotoCurrent: true "

    # write out datepicker options
    # see http://jqueryui.com/demos/datepicker/#options for available list
    date_picker_options.each do |key, value|
      html << ", #{key}: #{value}"
    end

    html << "    });"
    html << "  });"
    html << "</script>"
    html << "</div>" if has_error
    
    html.html_safe
  
  end
  
  def date_picker_tag(name, value, options={})
  
    date_picker_options = options.delete(:options) || {}

    html = ""
    html << text_field_tag(name, value, options)
    html << "<script type=\"text/javascript\">"
    html << "  $(function() {"
    html << "    $('##{name}').datepicker({"
    html << "         dateFormat: 'yy-mm-dd', "
    html << "         showOtherMonths: true, "
    html << "         selectOtherMonths: true, "
    html << "         constrainInput: true, "
    html << "         changeYear: true, "
    html << "         gotoCurrent: true "

    # write out datepicker options
    # see http://jqueryui.com/demos/datepicker/#options for available list
    date_picker_options.each do |key, value|
      html << ", #{key}: #{value}"
    end

    html << "    });"
    html << "  });"
    html << "</script>"
    
    html.html_safe
  
  end
  
end

ActionView::Helpers::FormBuilder.send(:include, DatePickerHelper)

