module AccountScopedModel

  class << self
    def included(klass)
      klass.class_eval do

        belongs_to :account

        validates :account, :presence => true, :existence => true

        before_create do
          # TODO: assign account to the current account
        end
        
        # TODO: ensure that the account has been assigned on validation...

      end
    end
  end

end
