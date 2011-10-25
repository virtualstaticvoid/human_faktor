Kaminari.configure do |config|
  config.default_per_page = Rails.env.development? ? 10 : 20
  config.window = 0
  config.outer_window = 0
  config.left = 0
  config.right = 0
  # config.param_name = :page
end
