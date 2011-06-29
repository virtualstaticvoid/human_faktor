module AccountScopedModel

  class << self
    def included(klass)
      klass.class_eval do

        validates :account_id, :presence => true
        belongs_to :account

        before_create do
          # TODO: assign account to the current account
        end

      end
    end
  end

end
