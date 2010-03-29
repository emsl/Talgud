class Admin::AccountsController < Admin::AdminController
  filter_resource_access
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage
  
  def index
    order = params[:order] ? params[:order] : {'order' => 'ascend_by_name'}
    @search = Account.with_permissions_to(:manage, :context => :admin_accounts).search(params[:search]).search(order)
    @accounts = @search.paginate(:page => params[:page])
  end
end