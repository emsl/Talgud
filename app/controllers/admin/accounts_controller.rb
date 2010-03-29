class Admin::AccountsController < Admin::AdminController
  filter_resource_access
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage
  
  def index
    order = params[:order] ? params[:order] : {'order' => 'ascend_by_name'}
    @search = Account.with_permissions_to(:manage, :context => :admin_accounts).search(params[:search]).search(order)
    @accounts = @search.paginate(:page => params[:page])
  end
  
  def edit
  end
  
  def update
<<<<<<< HEAD
    if @account.update_attributes(params[:account])
      flash[:notice] = t('admin.accounts.update.notice')
      redirect_to admin_accounts_path
    else
      flash.now[:error] = t('admin.accounts.update.error')
      render :action => :edit
    end    
  end
  
  def show
=======
>>>>>>> Account preferences.
  end
end