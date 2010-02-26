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
