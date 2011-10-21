module ApplicationHelper

  def self.safe_parse_date(value, default = nil)
    Date.parse(value)
  rescue
    default
  end

  def max(value1, value2)
    value1 < value2 ? value2 : value1
  end

  def min(value1, value2)
    value1 > value2 ? value2 : value1
  end

  def table_grid_row_click_handler
    javascript_tag do
      <<-JS
        $('.table_grid tbody').delegate('tr', 'click', function(e) {
          // figure out whether the row was clicked, or a link (or image) on the row (e.g. delete button)
          if (e.target.parentNode == this) {
            window.location = e.currentTarget.getAttribute('data-url');
          }
        });
      JS
    end
  end

end
