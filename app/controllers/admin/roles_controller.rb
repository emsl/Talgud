class Admin::RolesController < Admin::AdminController

  filter_resource_access :attribute_check => true
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage

  before_filter :load_target_model, :except => :index

  def index
    @search = Role.with_permissions_to(:manage, :context => :admin_roles).search(params[:search]).search(params[:order])
    @roles = @search.paginate(:page => params[:page])
    @target_model = Role.new
  end

  def new
    @role.model = @target_model
    @users = User.all(:include => [:roles])
  end

  def create
    @role.model = @target_model
    @users = User.all(:include => [:roles])
    if @role.save
      flash[:notice] = t('admin.roles.create.notice')
      redirect_to new_admin_role_path(:model_type => @target_model.class.name, :model_id => @target_model)
    else
      flash.now[:error] = t('admin.roles.create.error')
      render :action => :new
    end
  end

  def destroy
    @role.destroy
    flash[:notice] = t('admin.roles.destroy.notice')
    if params[:model_type] == 'Role'
      redirect_to admin_roles_path
    else
      redirect_to new_admin_role_path(:model_type => @target_model.class.name, :model_id => @target_model)
    end
  end

  protected
  # def load_role
  #   @role = Role.find(params[:id])
  #   if @role.model == 'Event' and not Event.can_manage(@current_user).find(@role.model.id)
  #     redirect_to admin_login_path
  #   end
  # end
  
  # Tries to detect target role model by parameter. Loads role symbols and all object permissions.
  def load_target_model
    id = params[:model_id] if params[:model_id]
    type = params[:model_type] if params[:model_type]

    @target_model =
    # TODO: find with permissions_to
    case type
    when 'County' then County.find(id)
    when 'Settlement' then Settlement.find(id)
    when 'Municipality' then Municipality.find(id)
    when 'Account' then Account.with_permissions_to(:read, :context => :admin_accounts).find(id)
    when 'Event' then Event.find_by_url(id)
    when 'Role' then Role.find(params[:id]).model
    end

    if @target_model
      @role_symbols = @target_model.class.try(:class_role_symbols)
      @roles = @target_model.try(:roles)
    else
      redirect_to admin_login_path
    end
  end
end
