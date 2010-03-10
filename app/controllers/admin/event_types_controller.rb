class Admin::EventTypesController < Admin::AdminController
  filter_resource_access
  filter_access_to [:new, :show, :create, :edit, :update, :destroy], :require => :manage

  def index
    @search = EventType.with_permissions_to(:manage, :context => :admin_event_types).search(params[:search])
    @event_types = @search.paginate(:page => params[:page])    
  end
  
  def show
  end

  def edit
  end
  
  def create
    if @event_type.save
      flash[:notice] = t('admin.event_types.create.notice')
      redirect_to admin_event_types_path
    else
      flash.now[:error] = t('admin.event_types.create.error')
      render :action => :new
    end
  end

  def update
    if @event_type.update_attributes(params[:event_type])
      flash[:notice] = t('admin.event_types.update.notice')
      redirect_to admin_event_types_path
    else
      flash.now[:error] = t('admin.event_types.update.error')
      render :action => :edit
    end
  end
  
  def destroy
    if @event_type.destroy
      flash[:notice] = t('admin.event_types.destroy.notice')
    else
      flash[:error] = t('admin.event_types.destroy.error')
    end
    redirect_to admin_event_types_path
  end  
end
