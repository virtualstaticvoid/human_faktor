class Country < ActiveRecord::Base

  default_scope order(:title)

  validates :iso_code, :presence => true, :uniqueness => true
  validates :title, :presence => true, :uniqueness => true
  
  def to_s
    self.title
  end
  
  def self.default
    @default_country ||= Country.find_by_iso_code(AppConfig.default_country_iso_code)
  end
  
end
