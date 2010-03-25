class Admin::UsersController < Admin::AdminController
  
  filter_resource_access :attribute_check => true
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage
  
  def index
    @search = User.with_permissions_to(:manage, :context => :admin_users).search(params[:search]).search(params[:order])
    @users = @search.paginate(:page => params[:page])
  end
  
  def new
  end

  def show
    @roles = @user.roles.all(:include => :model)
  end

  def edit
    @roles = @user.roles.all(:include => :model)
  end
  
  def create    
    if @user.save
      @user.activate!
      Mailers::UserMailer.deliver_registration_notification(@user, params[:user][:password], @current_user, login_url)
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
      @roles = @user.roles.all(:include => :model)
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
