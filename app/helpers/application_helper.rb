module ApplicationHelper

  def max(value1, value2)
    value1 < value2 ? value2 : value1
  end

  def min(value1, value2)
    value1 > value2 ? value2 : value1
  end

  def format_duration(value)
    (value == 0 || value.nil?) ? '-' : number_with_precision(value, :precision => 2)
  end

  def table_grid_row_click_handler
    javascript_tag do
      script = <<-JS
        $('.table_grid tbody').delegate('tr', 'click', function(e) {
          // figure out whether the row was clicked, or a link (or image) on the row (e.g. delete button)
          if (e.target.parentNode == this) {
            window.location = e.currentTarget.getAttribute('data-url');
          }
        });
      JS

      script.html_safe
    end
  end

  # NNB: this demo data must exist, and is created in the seeds
  def auth_token(account = nil, employee = nil)
    account = Account.find_by_subdomain('demo') unless account
    employee = account.employees.find_by_user_name('demo.user') unless employee
    unless employee.nil?
      employee.ensure_authentication_token!
      employee.authentication_token
    end
  end

end
