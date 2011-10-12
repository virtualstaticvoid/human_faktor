ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'cover_me'

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")
DEFAULT_ACCOUNT = :one

class ActiveSupport::TestCase
  
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def for_each_fixture(name, &block)
    Fixtures.all_loaded_fixtures[name].keys.each {|key| block.call key } 
  end
  
  def assert_valid(model)
    assert !model.nil?
    
    unless model.valid?
      puts ""
      puts "INVALID MODEL: #{model.class} => #{model.errors.full_messages}"
      puts caller.inspect
      puts ""

      assert false
    end
    
  end
  
end

class ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @account = accounts(DEFAULT_ACCOUNT)
  end

  def sign_in_as(role)
    sign_in employees(role)
  end

end

# put reCAPTCHA into test mode!
Rack::Recaptcha.test_mode! :return => true


