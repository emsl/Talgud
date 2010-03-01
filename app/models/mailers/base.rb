class Mailers::Base < ActionMailer::Base
  
  protected
  
  def full_from_address
    "#{Talgud.config.mailer.from_name} <#{Talgud.config.mailer.from_address}>"
  end
  
  def from_address
    Talgud.config.mailer.from_address
  end

  # Runs a block of code with given Rails locale. After the block has been finished, previously used locale will be set
  # back again.
  def with_locale(locale, &block)
    previous_locale = I18n.locale
    I18n.locale = locale if locale
    
    yield
    
    I18n.locale = previous_locale
  end
end
