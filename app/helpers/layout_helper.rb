module LayoutHelper

  def title(title)
    content_for(:title) { h(title.to_s) }
  end
  
  def head(&block)
    content_for(:head) do
      block.call
    end
  end
  
  def robots(value)
    content_for(:robots) { h(value.to_s) }
  end

  def content_title(title)
    content_for(:content_title) { h(title.to_s) }
  end 
  
  def content_header(&block)
    content_for(:content_header) do
      block.call
    end
  end

  def content_footer(&block)
    content_for(:content_footer) do
      block.call
    end
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

end
