class Admin::EventsController < Admin::AdminController

  filter_resource_access :additional_collection => :map, :attribute_check => true
  filter_access_to [:new, :show, :create, :edit, :update], :require => :manage

  def index
    @search = Event.can_manage(@current_user).search(params[:search]).search(params[:order])
    respond_to do |format|
      format.html { @events = @search.paginate(:page => params[:page]) }
      format.xml { render :xml => @search.all }
      format.csv { @events = @search.all; render_csv("events-#{Time.now.strftime("%Y%m%d")}") }
      format.xls { @events = @search.all }
    end
  end

  def map
    @events = Event.can_manage(@current_user)
  end

  def show
    @roles = @event.roles.all(:include => :model)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event }
      format.csv  { render_csv("event-#{@event.code}") }
      format.xls
    end
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
      @roles = @event.roles.all(:include => :model)
      render :action => :edit
    end
  end

  protected

  def load_event
    @event = Event.can_manage(@current_user).find(params[:id])
  end

  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end
    
    if @event
      @events = Array.new
      @events << @event
    end

    # todo: add column separator to application config
    events_csv = FasterCSV.generate :col_sep => ';' do |csv|
      # header row
      csv << [t('formtastic.labels.event.code'), 
        t('formtastic.labels.event.name'),
        t('formtastic.labels.event.event_type'),
        t('formtastic.labels.event.location_address_street'),
        t('formtastic.labels.event.meta_aim_description'),
        t('formtastic.labels.event.meta_job_description'),
        t('formtastic.labels.event.max_participants'),
        t('formtastic.labels.event.current_participants'), 
        t('formtastic.labels.event.begins_at'),
        t('formtastic.labels.event.ends_at'),
        t('formtastic.labels.event.meta_bring_with_you'),
        t('formtastic.labels.event.meta_provided_for_participiants'),
        t('formtastic.labels.event.languages'),
        t('formtastic.labels.event.gathering_location'),
        t('formtastic.labels.event.notes'),
        t('formtastic.labels.event.meta_subject_owner'),
        t('formtastic.labels.event.meta_subject_protegee'),
        t('formtastic.labels.event.meta_subject_heritage_number'),
        t('formtastic.labels.event.status')]
      # data rows
      @events.each do |event|
        csv << [event.code,
          event.name,
          event.event_type.name,
          event.location_address,
          event.meta_aim_description,
          event.meta_job_description,
          event.max_participants,
          event.current_participants,
          event.begins_at,
          event.ends_at,
          event.meta_bring_with_you,
          event.meta_provided_for_participiants,
          event.languages.collect(&:name) * ' ',
          event.gathering_location,
          event.notes,
          event.meta_subject_owner,
          event.meta_subject_protegee,
          event.meta_subject_heritage_number,
          t("formtastic.labels.event.statuses.#{event.status}")
        ]
      end
    end
    send_data(events_csv, :type => 'text/csv', :filename => filename)
  end
end
