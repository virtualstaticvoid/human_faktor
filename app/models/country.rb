class Country < ActiveRecord::Base

  def self.default
    @default_country ||= Country.find_by_iso_code(AppConfig.default_country_iso_code)
  end
  
  default_scope order(:title)

  validates :iso_code, :presence => true, :length => { :is => 2 }, :uniqueness => true
  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => true
  
  def to_s
    self.title
  end
  
end
