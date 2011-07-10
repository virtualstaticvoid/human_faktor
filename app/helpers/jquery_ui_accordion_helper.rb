module JqueryUiAccordionHelper

  def render_accordion(options = {}, &block)
  
    # insert defaults
    options[:id] = "accordion" unless options[:id]

    pane_builder = PaneBuilder.new
    
    # NB: must be a call to capture, so it behaves like content_for
    capture(pane_builder, &block)     
  
    html = "<div id=\"#{options[:id]}\" style=\""
    html << "width: #{options[:width]};" if options[:width]
    html << "height: #{options[:height]};" if options[:height]
    html << "\""
    html << " class=\"#{options[:class]}\"" if options[:class]
    html << ">"
    
    pane_builder.panes.each do |title, block|
    
      html << "<h3><a href=\"#\">#{title}</a></h3>"
      html << "<div>"
      
      # NB: must be a call to capture, so it behaves like content_for
      content = capture(&block)
      html << content if content.present?
      
      html << "</div>"
    end
    html << "</div>"
    
    html << "<script type=\"text/javascript\">"
    html << "$(function() { $(\"##{options[:id]}\").accordion({ fillSpace: true }); });"
    html << "</script>"

    raw(html)
    
  end
  
  class PaneBuilder

    attr_reader :panes
    attr_reader :options

    def initialize()
      @panes = {}
      @options = {}
    end
  
    def add_pane(title, options = {}, &block)
      @panes[title] = block
      @options[title] = options
    end
  
  end
end
