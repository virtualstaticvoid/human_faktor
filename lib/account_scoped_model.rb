module AccountScopedModel

  class << self
    def included(klass)
      klass.class_eval do

        belongs_to :account

        validates :account, :existence => true

      end
    end
  end

end
