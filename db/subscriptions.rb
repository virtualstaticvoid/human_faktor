#
# Subscriptions
#

def add_subscription(title, description, employee_price, max_employees, threshold = 1)

  monthly_price = employee_price * max_employees
  annual_price = (monthly_price * 12) - (monthly_price * 1.20)
  tri_annual_price = annual_price * 0.90

  subscription1 = Subscription.create!(
    :title => "#{title} Monthly (1-#{max_employees} employees)",
    :description => "#{description} sized businesses, 1 month contract, charged monthly in advance",
    :price => monthly_price.round(),
    :max_employees => max_employees,
    :threshold => threshold,
    :price_over_threshold => employee_price,
    :duration => 1 * 1,
    :active => true
  )

  subscription2 = Subscription.create!(
    :title => "#{title} 1 Year (1-#{max_employees} employees)",
    :description => "#{description} sized businesses, 1 year contract, charged annually in advance",
    :price => annual_price.round(),
    :max_employees => max_employees,
    :threshold => threshold,
    :price_over_threshold => employee_price,
    :duration => 12 * 1,
    :active => true
  )

  subscription3 = Subscription.create!(
    :title => "#{title} 3 Year (1-#{max_employees} employees)",
    :description => "#{description} sized businesses, 3 year contract, charged annually in advance",
    :price => tri_annual_price.round(),
    :max_employees => max_employees,
    :threshold => threshold,
    :price_over_threshold => employee_price,
    :duration => 12 * 3,
    :active => true
  )

  [subscription1, subscription2, subscription3]
end

# ... Free Trial subscription

Subscription.create!(
  :title => 'Free trial',
  :description => 'Free trial (1-25 employees)',
  :price => 0,
  :max_employees => 25,
  :threshold => 1,
  :price_over_threshold => 0,
  :duration => 3,
  :active => true
)

# ... Subscription Plans (as per spreadsheet)

add_subscription 'Small', 'Small',                    5.00,   25
add_subscription 'Small-Medium', 'Small to medium',   4.75,   50
add_subscription 'Medium', 'Medium',                  4.50,  100
add_subscription 'Medium-Large', 'Medium to large',   4.25,  150
add_subscription 'Large', 'Large',                    4.00,  300
add_subscription 'Enterprise', 'Enterprise',          3.50,  500
add_subscription 'Enterprise+', 'Large Enterprise',   3.00, 1000

