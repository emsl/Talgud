class Admin::UserSessionsController < Admin::AdminController
  
  skip_before_filter :require_user
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = t('user_sessions.create.notice')
      redirect_to admin_events_path
    else
      flash[:error] = t('user_sessions.create.error')
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to admin_login_path
  end
end
