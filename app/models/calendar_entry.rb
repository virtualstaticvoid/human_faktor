class CalendarEntry < ActiveRecord::Base

  default_scope order(:entry_date)
  
  belongs_to :country

  validates :country, :presence => true, :existence => true
  validates :title, :presence => true
  validates :entry_date, :presence => true, :timeliness => { :type => :date }
  
  def to_s
    self.title
  end

end
