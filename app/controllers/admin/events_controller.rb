class Admin::EventsController < Admin::AdminController
  
  filter_resource_access :additional_collection => :map, :attribute_check => true
  
  def index
    @events = Event.with_permissions_to(:manage, :context => :admin_events).all(:include => [:manager, :location_address_county, :location_address_municipality, :location_address_settlement])
  end
  
  def map
    @events = Event.with_permissions_to(:manage, :context => :admin_events)
  end
  
  def show
    @event = Event.with_permissions_to(:manage, :context => :admin_events).find(params[:id].to_i)
  end
  
  def update
    @event.status = params[:event][:status]
    if @event.save
      flash[:notice] = t('admin.events.update.notice')
      redirect_to admin_event_path(@event.id)
    else
      flash.now[:error] = t('admin.events.update.error')
      render :action => :show
    end
  end
end
