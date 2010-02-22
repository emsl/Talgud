class Admin::UsersController < Admin::AdminController
  filter_resource_access
  
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = t('admin.users.create.notice')
      redirect_to admin_users_path
    else
      flash.now[:error] = t('admin.users.create.error')
      render :action => :new
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = t('admin.users.update.notice')
      redirect_to admin_users_path
    else
      flash.now[:error] = t('admin.users.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = t('admin.users.destroy.notice')
    else
      flash[:error] = t('admin.users.destroy.error')
    end
    redirect_to admin_users_path
  end  
end
