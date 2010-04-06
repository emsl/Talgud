require 'yaml'
require 'ostruct'

class NestedOpenStruct < OpenStruct
  def initialize(hash = nil)
    @table = {}
    if hash
      for k, v in hash
        @table[k.to_sym] = v.instance_of?(Hash) ? NestedOpenStruct.new(v) : v
        new_ostruct_member(k)
      end
    end
  end
end

module Talgud
  class << self
    attr_accessor :config
  end
end

Talgud.config = NestedOpenStruct.new(YAML.load_file(RAILS_ROOT + "/config/app_config.yml")[RAILS_ENV])

if Talgud.config.mailer.delivery_method == 'smtp'
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = Talgud.config.mailer.smtp_settings.marshal_dump
end
