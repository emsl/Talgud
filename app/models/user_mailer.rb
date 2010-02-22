class UserMailer < ActionMailer::Base
  
  def activation_instructions(user, account_activation_url)
    subject I18n.t('user_mailer.activation_instructions.subject')
    from 'no-reply@fraktal.ee'
    recipients user.email
    sent_on Time.now
    body :user => user, :account_activation_url => account_activation_url
  end
  
  def password_reminder(user, password, login_url)
    subject I18n.t('user_mailer.password_reminder.subject')
    from 'no-reply@fraktal.ee'
    recipients user.email
    sent_on Time.now
    body :user => user, :password => password, :login_url => login_url
  end
end
