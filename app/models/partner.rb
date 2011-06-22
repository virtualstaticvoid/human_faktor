class Partner < ActiveRecord::Base

  default_scope order(:title)

  validates :title, :presence => true, :uniqueness => true

  def to_s
    self.title
  end

end
