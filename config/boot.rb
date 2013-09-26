require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'yaml'

# Load environment variables
env_config_filename = File.expand_path("../environment.yml", __FILE__)
if File.exist?(env_config_filename)
  env_config = File.read(env_config_filename)
  YAML.load(env_config).each do |key, value|
    #puts "Loading #{key} environment setting..."
    ENV[key] = value
  end
end
