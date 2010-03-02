class PasswordRemindersController < ApplicationController
  
  def create
    user = User.find_by_email(params[:password_reminder][:email])
    if user
      new_pwd = user.reset_password!
      
      Mailers::UserMailer.deliver_password_reminder(user, new_pwd, login_url)
      
      flash[:notice] = t('password_reminders.create.notice')
    else
      flash[:error] = t('password_reminders.create.error')
    end
    redirect_to login_path
  end
end
