class Admin::EventsController < Admin::AdminController
  
  filter_resource_access :additional_collection => :map, :attribute_check => true
  filter_access_to [:new, :show, :create, :edit, :update], :require => :read
  
  def index
    @search = Event.can_manage(@current_user).search(params[:search]).search(params[:order])
    @events = @search.paginate(:page => params[:page])
  end
  
  def map
    @events = Event.can_manage(@current_user)
  end
  
  def show
    @roles = @event.roles.all(:include => :model)
  end
  
  def edit
    @roles = @event.roles.all(:include => :model)
  end
  
  def update
    if @event.update_attributes(params[:event])
      flash[:notice] = t('admin.events.update.notice')
      redirect_to admin_event_path(@event.id)
    else
      flash.now[:error] = t('admin.events.update.error')
      render :action => :edit
    end
  end
end