class UsersController < ApplicationController
  
  filter_resource_access :attribute_check => true
  
  def edit
  end
  
  def update
    @user.attributes = params[:user]
    if @user.valid?
      @user.save
      flash[:notice] = t('users.update.notice')
      redirect_to edit_user_path(@user)
    else
      flash[:error] = t('users.update.error')
      render :edit
    end
  end

  private
  
  def load_user
    @user = current_user
  end

end
