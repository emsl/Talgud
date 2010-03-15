class Admin::EventParticipantsController < Admin::AdminController

  before_filter :load_event  
  filter_resource_access :attribute_check => true  
  filter_access_to [:new, :show, :create, :edit, :update], :require => :manage

  def index
    @search = @event.event_participants.search(params[:search]).search(params[:order])
    respond_to do |format|
      format.html { @event_participants = @search.paginate(:page => params[:page]) }
      format.xml  { render :xml => @search.all }
      format.csv { @event_participants = @search.all; render_csv("event-participans-#{Time.now.strftime("%Y%m%d")}") }
    end
  end

  def new
    @event_participant = EventParticipant.new(:event => @event)
  end
  
  def create
    @event_participant = EventParticipant.new(params[:event_participant])
    @event_participant.event = @event

    if @event_participant.valid?
      @event_participant.save

      # Deliver load of emails to all parties that might be interested in such participation
      Mailers::EventMailer.deliver_participant_notification(@event_participant, event_url(@event), event_participation_url(@event, UrlStore.encode(@event_participant.id)))
      @event.managers.each do |manager|
        Mailers::EventMailer.deliver_manager_participation_notification(manager, @event_participant, event_participations_url(@event))
      end
      @event_participant.recommend_emails.each do |email|
        Mailers::EventMailer.deliver_tell_friend_notification(email, @event_participant, event_url(@event))
      end

      flash[:notice] = t('admin.event_participants.create.notice')
      redirect_to admin_event_participations_path(@event.id)
    else
      flash.now[:error] = t('admin.event_participants.create.error')
      render :new
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @event_participant }
    end
  end

  def edit
  end

  def update
    @event_participant.attributes = params[:event_participant]
    if @event_participant.valid?
      @event_participant.save
      flash[:notice] = t('admin.event_participants.update.notice')
      redirect_to admin_event_participations_path(@event.id)
    else
      flash.now[:error] = t('admin.event_participants.update.error')
      render :show
    end
  end

  def destroy
    if @event_participant.destroy
      flash[:notice] = t('admin.event_participants.destroy.notice')
    else
      flash[:error] = t('admin.event_participants.destroy.error')
    end
    redirect_to admin_event_participations_path(@event.id)
  end  

  protected

  def load_event
    @event = Event.can_manage(@current_user).find(params[:event_id])
  end

  def load_event_participant
    p params
    @event_participant = @event.event_participants.find(params[:id])
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

    # todo: add column separator to application config
    events_csv = FasterCSV.generate :col_sep => ';' do |csv|
      # header row
      csv << [t('formtastic.labels.event.code'), 
        t('formtastic.labels.event.name'),
        t('formtastic.labels.event.max_participants'),        
        t('formtastic.labels.event.current_participants'),        
        t('formtastic.labels.event.vacancies'),        
        t('formtastic.labels.event_participant.firstname'),
        t('formtastic.labels.event_participant.lastname'),
        t('formtastic.labels.event_participant.email'),
        t('formtastic.labels.event_participant.phone'),
        t('formtastic.labels.event_participant.notes')
      ]
      # data rows
      @event_participants.each do |participant|
        csv << [participant.event.code,
          participant.event.name,
          participant.event.max_participants,
          participant.event.current_participants,
          participant.event.vacancies,
          participant.firstname,
          participant.lastname,
          participant.email,
          participant.phone,
          participant.notes
        ]
      end
    end
    send_data(events_csv, :type => 'text/csv', :filename => filename)
  end
end
