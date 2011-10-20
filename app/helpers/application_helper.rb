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

  # NNB: this demo data must exist, and is created in the seeds
  def demo_auth_token
    demo_account = Account.find_by_subdomain('demo')
    demo_user = demo_account.employees.find_by_user_name('demo.user')
    demo_user.ensure_authentication_token!
    demo_user.authentication_token
  end

end
