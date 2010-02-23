class EventsController < ApplicationController
  
  filter_resource_access
  
  def index
    @events = Event.all
  end
  
  def new
  end
  
  def create
    @event = Event.new(params[:event])
    @event.manager = current_user
    @event.location_address_country_code = 'ee'
    if @event.valid?
      @event.save
      flash[:notice] = t('events.create.notice')
      redirect_to events_path
    else
      render :new
      flash[:error] = t('events.create.error')
    end
  end
  
  def show
    @events = Event.all(:origin => [@event.latitude, @event.longitude], :within => 10)
  end
  
  protected
  
  def load_event
    @event = Event.find_by_url(params[:id])
  end
end
