module ColorPickerHelper
  def color_picker(method, options={})
    
    default_colors = %w{
      FFFFFF FFDFDF FFBFBF FF9F9F FF7F7F FF5F5F 
      FF3F3F FF1F1F FF0000 DF1F00 C33B00 A75700 
      8B7300 6F8F00 53AB00 37C700 1BE300 00FF00 
      00DF1F 00C33B 00A757 008B73 006F8F 0053AB 
      0037C7 001BE3 0000FF 0000DF 0000C3 0000A7 
      00008B 00006F 000053 000037 00001B 000000
    }.freeze
    
    selected_color = @object.send(method)
    
    options[:available] ||= default_colors

    sanitized_object_name ||= @object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    sanitized_method_name ||= method.to_s.sub(/\?$/,"")
    has_error = @object.errors[method].present?
    
    html = ""
    html << "<div class=\"field_with_errors\">" if has_error
    html << "<select id=\"id_#{sanitized_object_name}_#{sanitized_method_name}\" name=\"#{@object_name.to_s}[#{method.to_s}]\">"
    options[:available].each do |color|
      html << "<option value=\"#{color}\""
      html << " selected=\"selected\"" if color == selected_color
      html << ">#{color}</option>" 
    end
    html << "</select>"
    
    html << "<script type=\"text/javascript\">"
    html << "$('#id_#{sanitized_object_name}_#{sanitized_method_name}').colorpicker({"
    html << "size: 32"
    html << ", label: '#{options[:title]}'" if options[:title]
    html << "}); "
    html << "</script>"
    html << "</div>" if has_error

    html.html_safe
    
  end
end

ActionView::Helpers::FormBuilder.send(:include, ColorPickerHelper)

