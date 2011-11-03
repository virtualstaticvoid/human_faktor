class Country < ActiveRecord::Base

  def self.default
    @default_country ||= Country.find_by_iso_code(AppConfig.default_country_iso_code)
  end

  def self.by_iso_code(iso_code)
    Country.find_by_iso_code(iso_code.downcase) || self.default
  end
  
  before_save :downcase_iso_code

  default_scope order(:title)

  validates :iso_code, :presence => true, :length => { :is => 2 }, :uniqueness => true
  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => true

  validates :currency_symbol, :presence => true, :length => { :maximum => 3 }, :allow_nil => true
  validates :currency_code, :presence => true, :length => { :maximum => 3 }, :allow_nil => true
  
  has_many :calendar_entries, :dependent => :destroy

  def to_s
    self.title
  end
  
  private
  
  def downcase_iso_code
    self.iso_code.downcase!
  end
  
end
