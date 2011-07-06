class AccountSubscription < ActiveRecord::Base

  default_scope order('from_date DESC')

  default_values :price => 0,
                 :threshold => 0,
                 :price_over_threshold => 0

  belongs_to :account

  validates :account, :existence => true  

  # validity period
  validates :from_date, :timeliness => { :type => :date}
  validates :to_date, :timeliness => { :type => :date}
  validate :from_date_must_occur_before_to_date, :to_date_must_occur_after_from_date

  # subscription details
  validates :title, :presence => true, :length => { :maximum => 255 }
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }
  validates :max_employees, :numericality => { :only_integer => true, :greater_than => 1 }
  validates :threshold, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }
  validates :price_over_threshold, :numericality => { :greater_than_or_equal_to => 0 }
  
  private
  
  def from_date_must_occur_before_to_date
    errors.add(:from_date, "can't be after the to date") if
      !(from_date.blank? || to_date.blank?) and from_date > to_date
  end

  def to_date_must_occur_after_from_date
    errors.add(:from_date, "can't be before the from date") if
      !(from_date.blank? || to_date.blank?) and to_date < from_date
  end

end
