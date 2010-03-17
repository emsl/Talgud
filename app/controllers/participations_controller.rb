class ParticipationsController < ApplicationController

  before_filter :load_event, :except => :redirect
  before_filter :load_event_participant, :only => [:show, :update, :redirect]

  def index
    @search = @event.event_participants.search(:ordered_by_name => true)
    #@event_participants = @event.event_participants.paginate(:order => 'firstname, lastname')
    respond_to do |format|
      format.html { @event_participants = @search.paginate(:page => params[:page]) }
      format.csv { @event_participants = @search.all; @filename = "event-participans-#{@event.code}-#{Time.now.strftime("%Y%m%d")}.csv" }
      format.xls { @event_participants = @search.all; @filename = "event-participans-#{@event.code}-#{Time.now.strftime("%Y%m%d")}.xls"}
    end
  end

  def new
    @event_participant = EventParticipant.new(:event => @event)
    @event_participant.children = Array.new(3) { |i| EventParticipant.new }
    unless @event.vacancies?
      flash[:error] = t('participations.new.no_vacancies')
      redirect_to event_path(@event)
    end
  end

  def create
    @event_participant = EventParticipant.new(params[:event_participant])
    @event_participant.event = @event
    # Need to set parent records for validation
    @event_participant.children.each { |c| c.event_participant = @event_participant }

    if @event_participant.valid? & @event_participant.children_valid?
      @event_participant.save

      # Deliver load of emails to all parties that might be interested in such participation
      Mailers::EventMailer.deliver_participant_notification(@event_participant, event_url(@event), event_participation_redirect_url(UrlStore.encode(@event_participant.id)))
      @event_participant.children.select{ |c| not c.email.blank? }.each do |event_participant|
        Mailers::EventMailer.deliver_invite_participant_notification(event_participant, event_url(@event), event_participation_redirect_url(UrlStore.encode(event_participant.id)))
      end
      @event.managers.each do |manager|
        Mailers::EventMailer.deliver_manager_participation_notification(manager, @event_participant, event_participations_url(@event))
      end
      @event_participant.recommend_emails.each do |email|
        Mailers::EventMailer.deliver_tell_friend_notification(email, @event_participant, event_url(@event))
      end

      redirect_to confirmation_event_participation_path(@event, UrlStore.encode(@event_participant.id))
    else
      flash.now[:error] = t('participations.create.error')
      render :new
    end
  end

  def show
  end

  def update
    @event_participant.attributes = params[:event_participant]
    if @event_participant.valid? & @event_participant.children_valid?
      @event_participant.save
      flash[:notice] = t('participations.update.notice')
      redirect_to event_path(@event)
    else
      flash.now[:error] = t('participations.update.error')
      render :show
    end
  end
  
  def destroy
    @event_participant = EventParticipant.find(params[:id])
    @event_participant.destroy
    
    flash[:notice] = t('participations.destroy.notice')
    redirect_to event_participations_path(@event)
  end

  def redirect
    if @event_participant
      redirect_to(event_participation_path(@event_participant.event, params[:id]))
    else
      redirect_to(root_path)
    end
  end

  private

  def load_event
    redirect_to(root_path) and return if ['index', 'destroy'].include?(action_name) and not @current_user

    @event = if @current_user
      Event.can_manage(@current_user).find_by_url(params[:event_id])
    else
      Event.find_by_url(params[:event_id])
    end
    redirect_to(root_path) unless @event
  end

  def load_event_participant
    if id = UrlStore.decode(params[:id])
      @event_participant = EventParticipant.find(id)
    else
      if @event
        redirect_to event_path(@event) 
      else
        redirect_to root_path
      end
    end
  end
end
