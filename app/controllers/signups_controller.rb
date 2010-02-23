class SignupsController < ApplicationController
  #filter_resource_access :model => :users
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:signup])
    if @user.valid?
      @user.save_without_session_maintenance
      UserMailer.deliver_activation_instructions(@user, activate_url(@user.perishable_token))
    else
      flash[:error] = t('signups.create.error')
      render :new
    end
  end
  
  def activate
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)
    if @user and not @user.active?
      @user.activate!
      flash[:notice] = t('signups.activate.activation_successful')
      redirect_to new_event_path
    elsif @user and @user.active?
      flash[:error] = t('signups.activate.user_has_been_activated')
      redirect_to login_path
    else
      flash[:error] = t('signups.activate.invalid_activation_code')
      redirect_to signup_path
    end
  end
end
