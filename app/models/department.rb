class Department < ActiveRecord::Base
  include AccountScopedModel

  default_scope order(:title)
  
  validates :title, :presence => true, :length => { :maximum => 255 }, :uniqueness => { :scope => [:account_id] }

  def to_s
    self.title
  end

end
