class EventsController < ApplicationController

  filter_resource_access :additional_collection => [:my, :map, :latest, :stats], :attribute_check => true
  
  helper :photogallery
  
  cache_sweeper :event_sweeper, :only => [:create, :update]
  
  caches_action :map, :if => Proc.new { |c| c.request.format.json? }

  def index
    @search = Event.published(
    :order => 'begins_at ASC',
    :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]
    ).search(filter_from_params)

    respond_to do |format|
      format.xml { render :xml => @search.all }
      format.html { @events = @search.paginate(:page => params[:page])}
      format.ics do
        @events = @search.all
        render :text => self.generate_ical
      end
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
    @search = Event.latest(limit).published.search(filter_from_params)

    respond_to do |format|
      format.html do
        @events = if limit 
          @search.all(:include => includes)
        else
          @search.paginate(:page => params[:page], :limit => limit, :include => includes)
        end
      end
      format.json do
        @events = @search.all(:include => includes)
        render :json => events_json_hash(@events)
      end
    end
  end

  def stats
    @event_count = Event.published.count
    @max_participants = Event.published.sum(:max_participants, :conditions => filter_from_params)
    @current_participants = Event.published.sum('case when current_participants > max_participants then max_participants else current_participants end').to_i
    @needed_participants = [(@max_participants - @current_participants), 0].max

    render :json => {
      :event_count => @event_count, :max_participants => @max_participants,
      :current_participants => @current_participants, :needed_participants => @needed_participants
    }
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
        @nearby_events = Event.published.all(:origin => [@event.latitude, @event.longitude], :within => 25, :limit => 10).delete_if{ |e| e == @event }
      end
      format.ics do
        @events = [@event]
        render :text => self.generate_ical
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

  def generate_ical
    cal = Icalendar::Calendar.new
    cal.custom_property("METHOD","PUBLISH")
    
    @events.each do |e|
      event = Icalendar::Event.new
      event.start = e.begins_at.strftime("%Y%m%dT%H%M%S")
      event.status = t("formtastic.labels.event.statuses.#{e.status}")
      event.end = e.ends_at.strftime("%Y%m%dT%H%M%S")
      event.last_modified = e.updated_at.strftime("%Y%m%dT%H%M%S")
      event.summary = e.label
      event.geo = [e.latitude, e.longitude] * ';'
      event.location = e.location_address
      event.uid = e.code
      event.categories = [e.event_type.name]
      event.contacts = e.managers.collect do |manager|
        [manager.name, manager.email, manager.phone].select{ |i| not i.blank? } * ', '
      end
      event.description = e.meta_subject_info
      event.url = event_url(e)
      event.organizer = event.contacts * '; '
      event.add_comment(root_url)
      cal.add event
    end
    
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    cal.publish
    cal.to_ical
  end

  private

  def filter_from_params
    conditions = {}
    conditions[:location_address_county_id] = params[:county] unless params[:county].blank?
    conditions[:event_type_id] = params[:event_type] unless params[:event_type].blank?
    conditions[:code] = params[:event_code] unless params[:event_code].blank?
    conditions[:languages_code_eq] = params[:language_code] unless params[:language_code].blank?
    conditions[:managers_firstname_or_managers_lastname_like_any] = params[:manager_name].split unless params[:manager_name].blank?
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
