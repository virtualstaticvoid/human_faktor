class <%= class_name %> < <%= parent_class_name.classify %>
<% attributes.select {|attr| attr.reference? }.each do |attribute| -%>
  belongs_to :<%= attribute.name %>
<% end -%>

  attr_accessible <%= attributes.map {|a| ":#{a.name}" }.join(', ') %>

<% attributes.each do |attribute| -%>
  validates :<%= attribute.name %>
<% end -%>

end
