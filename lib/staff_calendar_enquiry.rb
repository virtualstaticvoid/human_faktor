require 'date'
require 'informal'

class StaffCalendarEnquiry
  include Informal::Model
  
  attr_reader :account
  validates_presence_of :account
  
  attr_reader :employee
  validates_presence_of :employee

  attr_accessor :date_from
  validates :date_from, :timeliness => { :type => :date }
  
  attr_accessor :date_to
  validates :date_to, :timeliness => { :type => :date }

  validate :date_from_must_occur_before_date_to, 
           :date_to_must_occur_after_date_from,
           :duration_at_least_one_month

  def initialize(account, employee)
    @account = account
    @employee = employee
  end

  private
  
  def date_from_must_occur_before_date_to
    errors.add(:date_from, "can't be after the to date") if
      !(date_from.blank? || date_to.blank?) && (date_from > date_to)
  end

  def date_to_must_occur_after_date_from
    errors.add(:date_to, "can't be before the from date") if
      !(date_from.blank? || date_to.blank?) && (date_to < date_from)
  end

  def duration_at_least_one_month
    errors.add(:base, "date window needs to be at least 7 days") if
      (date_to - date_from) < 7
  end
  
end
