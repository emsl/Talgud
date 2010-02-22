RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.gem 'authlogic'
  # config.gem 'url_store'
  config.gem 'formtastic'
  # config.gem 'acts_as_audited'
  # config.gem 'declarative_authorization'
  # config.gem 'will_paginate'  
  config.gem 'stringex'
  
  config.frameworks -= [:active_resource]

  config.time_zone = 'Tallinn'
  config.i18n.default_locale = :et
end