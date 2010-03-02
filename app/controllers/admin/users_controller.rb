class Admin::UsersController < Admin::AdminController
  
  filter_resource_access :attribute_check => true
  
  def index
    @users = User.with_permissions_to(:manage, :context => :admin_users).all
  end
  
  def new
  end

  def show
  end

  def edit
    @roles = @user.roles.all(:include => :model)
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
