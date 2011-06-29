module JavascriptTagHelper

  def javascript_event_tag(name, event, &block)
    content = "Event.observe('#{name}', '#{event}', function() {"
    content << update_page(&block)
    content << "});"
    content_tag(:script, javascript_cdata_section(content))
  end

end
