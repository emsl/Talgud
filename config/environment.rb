RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.load_paths += %W( #{RAILS_ROOT}/app/middleware #{RAILS_ROOT}/app/sweepers )

  config.gem 'authlogic', :version => '2.1.3'
  config.gem 'formtastic'
  config.gem 'declarative_authorization'
  # config.gem 'will_paginate'
  config.gem 'stringex'
  config.gem 'geokit'
  config.gem 'newrelic_rpm'
  
  config.frameworks -= [:active_resource]

  config.time_zone = 'Tallinn'
  config.i18n.default_locale = :et
end

ActionController::Dispatcher.middleware.use Rack::JSONP
