ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'authlogic/test_case'

# Non standard spec locations (currently mailers) are being mapped inside {RAILS_ROOT}/.autotest file.

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Load shared examples from ./shared/ and its subdirectories
Dir["#{File.dirname(__FILE__)}/shared/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  # Initialize account context
  config.before(:each) do
    Account.current = Factory(:account)
  end
end
