module ApplicationHelper

  def self.safe_parse_date(value, default = nil)
    Date.parse(value)
  rescue
    default
  end

end
