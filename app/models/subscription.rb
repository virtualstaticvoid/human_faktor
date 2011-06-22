class Subscription < ActiveRecord::Base

  def self.default
    @default_subscription ||= Subscription.first
  end

  default_scope order(:sequence)
  scope :active, where(:active => true)  

  default_values :sequence => lambda { Subscription.count },
                 :price => 0,
                 :threshold => 0,
                 :price_over_threshold => 0,
                 :duration => 1,
                 :active => false

  validates :sequence, :numericality => { :only => :integer }
  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => true
  validates :description, :presence => true
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }
  validates :max_employees, :numericality => { :only_integer => true, :greater_than => 1 }
  validates :threshold, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }
  validates :price_over_threshold, :numericality => { :greater_than_or_equal_to => 0 }
  validates :duration, :numericality => { :greater_than_or_equal_to => 1 }
  validates :active, :inclusion => { :in => [true, false] }

  def to_s
    self.title
  end

end
