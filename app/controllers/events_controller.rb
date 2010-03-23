class EventsController < ApplicationController

  filter_resource_access :additional_collection => [:my, :map, :latest, :stats], :attribute_check => true

  def index
    @search = Event.published(
      :order => 'begins_at ASC', 
      :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]
    ).search(filter_from_params)
    
    respond_to do |format|
      format.xml { render :xml => @search.all }
      format.html { @events = @search.paginate(:page => params[:page]) }
    end
  end

  def my
    @events = Event.my_events(@current_user).paginate(
      :order => 'begins_at ASC', :page => params[:page],
      :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]
    )
  end

  def map
    respond_to do |format|
      format.html do
        @event_types = EventType.all
        @languages = Language.all
      end
      format.json do
        @events = Event.published.all(
          :conditions => filter_from_params,
          :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]
        )
        render :json => events_json_hash(@events)
      end
    end
  end

  def latest
    includes = [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]
    limit = (params[:limit].try(:to_i) || nil)

    respond_to do |format|
      format.html do
        @events = Event.latest.published.paginate(
        :conditions => filter_from_params, :order => 'id DESC', :limit => limit, :include => includes,
        :page => params[:page]
        )
      end
      format.json do
        @events = Event.latest.published.all(:order => 'id DESC', :limit => limit, :include => includes)
        render :json => events_json_hash(@events)
      end
    end
  end
  
  def stats
    @max_participants = Event.published.sum(:max_participants, :conditions => filter_from_params)
    @current_participants = Event.published.sum('case when current_participants > max_participants then max_participants else current_participants end').to_i
    @needed_participants = [(@max_participants - @current_participants), 0].max
    
    render :json => {:max_participants => @max_participants, :current_participants => @current_participants, :needed_participants => @needed_participants}
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
    @event.begin_time = params[:event][:begin_time] if params[:event][:begin_time]
    @event.end_time = params[:event][:end_time] if params[:event][:end_time]

    @event.manager = current_user
    # TODO: country code is hard coded. Must be configurable
    @event.location_address_country_code = 'ee'
    if @event.valid?
      @event.save

      @event.regional_managers.each do |rm|
        Mailers::EventMailer.deliver_region_manager_notification(rm, @event, admin_event_url(@event.id))
      end

      flash[:notice] = t('events.create.notice', :code => @event.code)
      redirect_to event_path(@event)
    else
      flash.now[:error] = t('events.create.error')
      render :new
    end
  end

  def show
    respond_to do |format|
      format.html do
        # TODO: nearby distance should be configurable
        @nearby_events = Event.published.all(:origin => [@event.latitude, @event.longitude], :within => 25, :limit => 10).delete_if{ |e| e == @event }
      end
      format.json { render :json => @event }
    end
  end

  def edit
  end

  def update
    @event.attributes = params[:event]
    if @event.valid?
      @event.save
      flash[:notice] = t('events.update.notice')
      redirect_to event_path(@event)
    else
      flash.now[:error] = t('events.update.error')
      render :new
    end
  end

  protected

  def load_event
    @event = Event.find_by_url(params[:id])
  end

  private

  def filter_from_params
    conditions = {}
    conditions[:location_address_county_id] = params[:county] unless params[:county].blank?
    conditions[:event_type_id] = params[:event_type] unless params[:event_type].blank?
    conditions[:code] = params[:event_code] unless params[:event_code].blank?
    conditions
  end

  def events_json_hash(events)
    events.inject(Array.new) do |memo, e|
      memo << {
        :name => e.name, :latitude => e.latitude, :longitude => e.longitude, :url => event_url(e),
        :event_type => e.event_type.name, :address => e.location_address, :vacancies => e.vacancies,
        :has_vacancies => e.vacancies?, :aim_desc => e.meta_aim_description, :job_desc => e.meta_job_description
      }
    end
  end
end
