class UserMailer < ActionMailer::Base
  
  def activation_instructions(user, account_activation_url)
    subject 'Activation instructions'
    from 'Talgud <no-reply@fraktal.ee>'
    recipients user.email
    sent_on Time.now
    body :user => user, :account_activation_url => account_activation_url
  end
  
  def password_reminder(user, password)
    subject 'Your new password!'
    from 'Taltud <no-reply@fraktal.ee>'
    recipients user.email
    sent_on Time.now
    body :user => user, :password => password
  end
end
