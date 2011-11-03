#
# Subscriptions by Country
#

def add_subscription(country, title, employee_price, max_employees, threshold = 1)

  monthly_price = employee_price * max_employees
  annual_price = (monthly_price * 12) - (monthly_price * 1.20)
  tri_annual_price = annual_price * 0.90

  subscription1 = Subscription.where(:max_employees => max_employees, :duration => 1).first
  subscription2 = Subscription.where(:max_employees => max_employees, :duration => 12).first
  subscription3 = Subscription.where(:max_employees => max_employees, :duration => 36).first

  SubscriptionCountry.create!(
    :subscription => subscription1,
    :country => country,
    :price => monthly_price.round(),
    :price_over_threshold => threshold
  )

  SubscriptionCountry.create!(
    :subscription => subscription2,
    :country => country,
    :price => annual_price.round(),
    :price_over_threshold => threshold
  )

  SubscriptionCountry.create!(
    :subscription => subscription3,
    :country => country,
    :price => tri_annual_price.round(),
    :price_over_threshold => threshold
  )

end

# ... Subscription Plans (as per spreadsheet)

us = Country.by_iso_code('us')
d = 1.0 / 8.0

add_subscription us, 'Small',          5.00 * d,   25
add_subscription us, 'Small-Medium',   4.75 * d,   50
add_subscription us, 'Medium',         4.50 * d,  100
add_subscription us, 'Medium-Large',   4.25 * d,  150
add_subscription us, 'Large',          4.00 * d,  300
add_subscription us, 'Enterprise',     3.50 * d,  500
add_subscription us, 'Enterprise+',    3.00 * d, 1000
