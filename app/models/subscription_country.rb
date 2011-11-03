class SubscriptionCountry < ActiveRecord::Base

  def self.prices_for(subscription, country)

    self.where(
      :subscription_id => subscription.id,
      :country_id => country.id
    ).first || new(
      :subscription => subscription,
      :country => country,
      :price => subscription.price,
      :price_over_threshold => subscription.price_over_threshold
    )

  end

  belongs_to :subscription
  belongs_to :country

  validates :subscription, :existence => true  
  validates :country, :existence => true

  validates :price, :numericality => { :greater_than_or_equal_to => 0 }
  validates :price_over_threshold, :numericality => { :greater_than_or_equal_to => 0 }

end
