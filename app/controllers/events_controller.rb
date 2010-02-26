class EventsController < ApplicationController
  
  filter_resource_access :additional_collection => [:my, :map], :attribute_check => true
  
  def index
    @events = Event.with_permissions_to(:read)
  end
  
  def my
    @events = Event.my_events(@current_user)
  end
  
  def map
    @events = Event.with_permissions_to(:read)
  end
  
  def new
  end
  
  def create
    @event = Event.new(params[:event])
    @event.manager = current_user
    @event.location_address_country_code = 'ee'
    if @event.valid?
      @event.save
      
      @event.regional_managers.each do |rm|
        Mailers::EventMailer.deliver_region_manager_notification(rm, @event, admin_event_url(@event.id))
      end
      
      flash[:notice] = t('events.create.notice')
      redirect_to event_path(@event)
    else
      render :new
      flash.now[:error] = t('events.create.error')
    end
  end
  
  def show
    @events = Event.with_permissions_to(:read).all(:origin => [@event.latitude, @event.longitude], :within => 10)
  end
  
  protected
  
  def load_event    
    @event = Event.find_by_url(params[:id])
  end
end