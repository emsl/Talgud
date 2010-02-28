class EventsController < ApplicationController
  
  filter_resource_access :additional_collection => [:my, :map], :attribute_check => true
  
  def index
    @events = Event.with_permissions_to(:read).all(:order => 'begins_at ASC', :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement])
  end
  
  def my
    @events = Event.my_events(@current_user).all(:order => 'begins_at ASC', :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement])
    # @events = Event.with_permissions_to(:my).all(:order => 'begins_at ASC', :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement])
  end
  
  def map
    @events = Event.with_permissions_to(:read).all(:select => 'name, latitude, longitude, url', :order => 'begins_at ASC')
    respond_to do |format|
      format.html
      format.json { render :json => events_json_hash(@events) }
    end
  end
  
  def new
    # TODO: date is currenlty hard coded
    @event.attributes = {:begins_at => DateTime.parse('2010-05-01 10:00'), :ends_at => DateTime.parse('2010-05-01 18:00')}
    @event.attributes = {:begin_time => '10:00', :end_time => '18:00'}
  end
  
  def create
    @event = Event.new(params[:event].merge(:begins_at => Date.parse('2010-05-01'), :ends_at => Date.parse('2010-05-01')))
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
    respond_to do |format|
      format.html
      format.json { render :json => @event }
    end
  end
  
  protected
  
  def load_event    
    @event = Event.find_by_url(params[:id])
  end
  
  private
  
  def events_json_hash(events)
    events.inject(Array.new) do |memo, e|
      memo << {:name => e.name, :latitude => e.latitude, :longitude => e.longitude, :url => event_path(e)}
    end
  end
  
end