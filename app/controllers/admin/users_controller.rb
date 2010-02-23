class Admin::UsersController < Admin::AdminController
  filter_resource_access
  
  def index
    @users = User.all
  end
  
  def new
  end

  def show
  end

  def edit
  end
  
  def create
    if @user.save
      flash[:notice] = t('admin.users.create.notice')
      redirect_to admin_users_path
    else
      flash.now[:error] = t('admin.users.create.error')
      render :action => :new
    end
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = t('admin.users.update.notice')
      redirect_to admin_users_path
    else
      flash.now[:error] = t('admin.users.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    if @user.destroy
      flash[:notice] = t('admin.users.destroy.notice')
    else
      flash[:error] = t('admin.users.destroy.error')
    end
    redirect_to admin_users_path
  end  
end
