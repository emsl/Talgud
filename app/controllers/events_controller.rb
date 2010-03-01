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
    respond_to do |format|
      format.html
      format.json do
        @events = Event.published.all(
          :select => 'name, latitude, longitude, url, max_participants, meta_aim_description, meta_job_description, event_type_id, location_address_county_id, location_address_municipality_id, location_address_settlement_id, location_address_street',
          :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]
        )
        
        render :json => events_json_hash(@events)
      end
    end
  end
  
  def new
    # TODO: date is currenlty hard coded.
    @event.attributes = {:begins_at => DateTime.parse('2010-05-01 10:00'), :ends_at => DateTime.parse('2010-05-01 18:00')}
    @event.attributes = {:begin_time => '10:00', :end_time => '18:00'}
  end
  
  def create
    @event = Event.new(params[:event])
    # TODO: date is currently hard coded.
    @event.begins_at = Date.parse('2010-05-01')
    @event.ends_at = Date.parse('2010-05-01')
    @event.begin_time = params[:event][:begin_time]
    @event.end_time = params[:event][:end_time]
    
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
      memo << {
        :name => e.name, :latitude => e.latitude, :longitude => e.longitude, :url => event_url(e),
        :event_type => e.event_type.name, :address => e.location_address, :vacancies => e.vacancies,
        :aim_desc => e.meta_aim_description, :job_desc => e.meta_job_description
      }
    end
  end
  
end