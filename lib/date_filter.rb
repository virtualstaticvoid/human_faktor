class DateFilter
  include Informal::Model

  attr_accessor :date_from
  attr_accessor :date_to

  attr_accessor :date_from
  validates :date_from, :timeliness => { :type => :date }
  
  attr_accessor :date_to
  validates :date_to, :timeliness => { :type => :date }

  validate :date_from_must_occur_before_date_to, 
           :date_to_must_occur_after_date_from

  private
  
  def date_from_must_occur_before_date_to
    errors.add(:date_from, "can't be after the to date") if
      !(date_from.blank? || date_to.blank?) && (date_from > date_to)
  end

  def date_to_must_occur_after_date_from
    errors.add(:date_to, "can't be before the from date") if
      !(date_from.blank? || date_to.blank?) && (date_to < date_from)
  end

end
