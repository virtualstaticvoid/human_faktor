class CalendarEntry < ActiveRecord::Base

  default_scope order(:entry_date)
  
  validates :country_id, :existence => true
  validates :title, :presence => true
  validates :entry_date, :presence => true, :timeliness => { :type => :date }

  belongs_to :country
  
  def to_s
    self.title
  end

end
