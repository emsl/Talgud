class Admin::RolesController < Admin::AdminController
  
  filter_resource_access :attribute_check => true
  
  before_filter :load_target_model, :except => :index

  def index
    @roles = Role.with_permissions_to(:manage, :context => :admin_users).all
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
    redirect_to new_admin_role_path(:model_type => @target_model.class.name, :model_id => @target_model)
  end

  protected
  # Tries to detect target role model by parameter. Loads role symbols and all object permissions.
  def load_target_model
    id = params[:model_id] if params[:model_id]
    type = params[:model_type] if params[:model_type]

    @target_model =
      case type
      when 'County' then County.find(id)
      when 'Settlement' then Settlement.find(id)
      when 'Municipality' then Municipality.find(id)      
      end

    if @target_model
      @role_symbols = @target_model.class.try(:class_role_symbols)
      @roles = @target_model.try(:roles)
    else
      redirect_to admin_path
    end
  end
end
