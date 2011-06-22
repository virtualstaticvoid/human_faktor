class Subscription < ActiveRecord::Base

  default_scope order(:sequence)

  validates :sequence, :numericality => { :only => :integer }
  validates :title, :presence => true, :uniqueness => true

  def to_s
    self.title
  end

end
