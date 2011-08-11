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

end
