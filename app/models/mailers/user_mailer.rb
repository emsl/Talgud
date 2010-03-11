class Mailers::UserMailer < Mailers::Base
  
  def activation_instructions(user, account_activation_url)
    subject I18n.t('mailers.user_mailer.activation_instructions.subject')
    from full_from_address
    headers 'return-path' => from_address
    recipients user.email
    sent_on Time.now
    body :user => user, :account_activation_url => account_activation_url
  end
  
  def password_reminder(user, password, login_url)
    subject I18n.t('mailers.user_mailer.password_reminder.subject')
    from full_from_address
    headers 'return-path' => from_address
    recipients user.email
    sent_on Time.now
    body :user => user, :password => password, :login_url => login_url
  end
  
  def registration_notification(user, password, creator, login_url)
    subject I18n.t('mailers.user_mailer.registration_notification.subject')
    from full_from_address
    headers 'return-path' => from_address
    recipients user.email
    sent_on Time.now
    body :user => user, :login_url => login_url, :creator => creator, :password => password
  end
end
