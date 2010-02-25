class Admin::EventsController < Admin::AdminController
  
  filter_resource_access :additional_collection => :map
  
  def index
    @events = Event.all(:include => [:manager, :location_address_county, :location_address_municipality, :location_address_settlement])
  end
  
  def map
    @events = Event.all
  end
  
  def show
    @event = Event.find(params[:id].to_i)
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
