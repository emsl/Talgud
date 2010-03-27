class Admin::EventParticipantsController < Admin::AdminController

  before_filter :load_event  
  filter_resource_access :attribute_check => true  
  filter_access_to [:new, :show, :create, :edit, :update], :require => :manage
  
  helper :participations

  def index
    @search = @event.event_participants.search(params[:search]).search(params[:order])
    respond_to do |format|
      format.xml { render :xml => @search.all }
      format.csv { @event_participants = @search.all; @filename = "event-participants-#{@event.code}-#{Time.now.strftime("%Y%m%d")}.csv" }
      format.xls { @event_participants = @search.all; @filename = "event-participants-#{@event.code}-#{Time.now.strftime("%Y%m%d")}.xls" }
      format.html { @event_participants = @search.paginate(:page => params[:page]) }
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
      Mailers::EventMailer.deliver_participant_notification(@event_participant, event_url(@event), event_participation_redirect_url(UrlStore.encode(@event_participant.id)))
      @event_participant.children.select{ |c| not c.email.blank? }.each do |event_participant|
        Mailers::EventMailer.deliver_invite_participant_notification(event_participant, event_url(@event), event_participation_redirect_url(UrlStore.encode(event_participant.id)))
      end
      @event.managers.each do |manager|
        Mailers::EventMailer.deliver_manager_participation_notification(manager, @event_participant, event_participations_url(@event))
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
    redirect_to admin_login_path unless @event
  end

  def load_event_participant
    @event_participant = @event.event_participants.find(params[:id])
  end
end