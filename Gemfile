source 'http://rubygems.org'

gem 'rails', '3.0.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

# Use unicorn as the web server
# gem 'unicorn'
gem 'thin'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'app_config', :git => 'git://github.com/virtualstaticvoid/app_config.git', :branch => 'master'
gem 'aws-s3', :require => 'aws/s3'
gem 'aws-ses', '~> 0.4.3', :require => 'aws/ses'
gem 'default_value_for', :git => 'git://github.com/virtualstaticvoid/default_value_for.git', :branch => 'master'
gem 'delayed_job'
gem 'devise', :git => 'git://github.com/virtualstaticvoid/devise.git', :branch => 'find_for_authentication'
gem 'foreman'
gem 'geoip'
gem 'informal', :git => 'git://github.com/virtualstaticvoid/informal.git', :branch => 'rails_3_0_model_name_back_port'
gem 'jquery-rails', '~> 1.0.3'
gem 'kaminari', '~> 0.12.4'
gem 'paperclip', '~> 2.3'
gem 'rack-recaptcha', :require => 'rack/recaptcha', :git => 'git://github.com/virtualstaticvoid/rack-recaptcha.git', :tag => 'v0.5.0'
gem 'validates_timeliness', '~> 3.0.2'
gem 'kmandrup-colorist', :git => 'git://github.com/virtualstaticvoid/colorist.git', :branch => 'master'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:

group :development, :test do
  gem 'cover_me'
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-test'
  gem 'libnotify'
  gem 'pry'
  gem 'rb-inotify'
  gem 'ruby-prof'
  gem 'test-unit'
end

# instrumentation
gem 'newrelic_rpm', :group => :production
