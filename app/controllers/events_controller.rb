class EventsController < ApplicationController

  filter_resource_access :additional_collection => [:my, :map, :latest, :stats, :past], :attribute_check => true
  
  helper :photogallery
  
  cache_sweeper :event_sweeper, :only => [:create, :update]
  
  caches_action :map, :if => :cache_action?.to_proc
  INCLUDES = [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]

  def index
    @search = Event.by_manager_name(filter_manager_name_from_params).by_language_code(filter_language_code_from_params).published(
      :order => 'begins_at ASC'
    )
    
    respond_to do |format|
      format.xml do
        @events = @search.paginate(:page => params[:page], :per_page => 10000, :conditions => filter_from_params, :include => INCLUDES)
        render :xml => @events
      end
      
      format.html { @events = @search.paginate(:page => params[:page], :conditions => filter_from_params, :include => INCLUDES) }
      format.ics do
        @events = @search.all
        render :text => self.generate_ical
      end
    end
  end

  def my
    @events = Event.my_events(@current_user).paginate(
    :page => params[:page],
    :include => [:event_type, :location_address_county, :location_address_municipality, :location_address_settlement]
    )
  end

  def past
    @events = Event.past.search(filter_from_params).paginate(
    :page => params[:page], 
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
        @events = Event.by_manager_name(filter_manager_name_from_params).by_language_code(filter_language_code_from_params).published.all(
          :conditions => filter_from_params,
          :include => INCLUDES
        )
        render :json => events_json_hash(@events)
      end
    end
  end

  def latest
    limit = (params[:limit].try(:to_i) || nil)
    @search = Event.by_manager_name(filter_manager_name_from_params).by_language_code(filter_language_code_from_params).latest(limit).published
    
    respond_to do |format|
      format.html do
        @events = @search.paginate(:page => params[:page], :per_page => limit, :include => INCLUDES, :conditions => filter_from_params)
      end
      format.json do
        @events = @search
        render :json => events_json_hash(@events)
      end
    end
  end

  def stats
    @event_count = Event.published.count
    @max_participants = Event.published.sum(:max_participants, :conditions => filter_from_params)
    @current_participants = Event.published.sum(:current_participants).to_i
    @needed_participants = [(@max_participants - @current_participants), 0].max

    render :json => {
      :event_count => @event_count, :max_participants => @max_participants,
      :current_participants => @current_participants, :needed_participants => @needed_participants
    }
  end

  def new
    # TODO: date is currenlty hard coded.
    @event.attributes = {:begins_at => 10.days.from_now, :ends_at => 10.days.from_now, :registration_begins_at => 7.days.from_now, :registration_ends_at => 9.days.from_now}
    @event.attributes = {:begin_time => '10:00', :end_time => '18:00', :registration_begin_time => '00:00', :registration_end_time => '00:00'}
  end

  def create
    @event = Event.new(params[:event])
    @event.manager = current_user    
    @event.status = if @event.instant_publish and Account.current.em_publish_event
      Event::STATUS[:published]
    else
      Event::STATUS[:new]
    end
    
    # TODO: country code is hard coded. Must be configurable
    @event.location_address_country_code = 'ee'
    if @event.valid?
      @event.save
      
      unless Account.current.em_publish_event
        @event.regional_managers.each do |rm|
          Mailers::EventMailer.deliver_region_manager_notification(rm, @event, admin_event_url(@event.id))
        end
      end

      if Account.current.em_publish_event
        if @event.status == Event::STATUS[:published] 
          flash[:notice] = t('events.create.em_published_notice', :code => @event.code)
        else
          flash[:notice] = t('events.create.em_notice', :code => @event.code)
        end
      else
        flash[:notice] = t('events.create.notice', :code => @event.code)
      end
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
    published = false
    if @event.publish and Account.current.em_publish_event
      @event.status = Event::STATUS[:published]
      published = true
    end
    if @event.valid?
      @event.save
      if published 
        flash[:notice] = t('events.update.em_published_notice')
      else
        flash[:notice] = t('events.update.notice')
      end
      redirect_to event_path(@event)
    else
      flash.now[:error] = t('events.update.error')
      render :new
    end
  end

  protected
  
  def cache_action?
    request.format.json? and [:county, :event_type, :event_code, :language_code, :manager_name].all? { |p| params[p].blank? }
  end

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

  def filter_manager_name_from_params
    params[:manager_name]
  end
  
  def filter_language_code_from_params
    params[:language_code]
  end

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
