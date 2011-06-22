class Partner < ActiveRecord::Base

  default_scope order(:title)

  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => true

  def to_s
    self.title
  end

end
