class Partner < ActiveRecord::Base

  default_scope order(:title)
  scope :active, where(:active => true)
  
  default_values :active => false

  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => true
  validates :contact_name, :presence => true, :length => { :maximum => 255 }
  validates :contact_email, :presence => true, :email => true
  validates :active, :inclusion => { :in => [true, false] }

  def to_s
    self.active ? self.title : "#{self.title} [Inactive]"
  end

end
