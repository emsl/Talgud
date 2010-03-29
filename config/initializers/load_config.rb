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

module ActionMailer
  class Base
    cattr_accessor :smtp_account_index

    # Overrides base smtp_settings accessor to enable multiple smtp accounts rotation. Accounts should be defined in
    # app_config.yml file as array in mailer.smtp_accounts like this.
    #
    #   development:
    #     mailer:
    #       smtp_accounts:
    #       - :user_name: foo@example.com
    #         :password: PWD_FOR_FOO
    #       - :user_name: bar@example.com
    #         :password: PWD_FOR_BAR
    #
    # If smtp_accounts configuration variable is omitted, it will fall back to the defaults defined in
    # ActionMailer::Base.smtp_settings
    def smtp_settings
      settings = @@smtp_settings
      if Talgud.config.mailer.try(:smtp_accounts).is_a?(Array)
        @@smtp_account_index ||= 0
        idx = (@@smtp_account_index += 1) % Talgud.config.mailer.smtp_accounts.size
        settings.merge(Talgud.config.mailer.smtp_accounts[idx])
      end
    end
  end
end
