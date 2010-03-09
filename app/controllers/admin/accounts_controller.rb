class Admin::AccountsController < Admin::AdminController
  filter_resource_access
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage
  
  def index
    @accounts = Account.with_permissions_to(:manage, :context => :admin_accounts)
  end
end