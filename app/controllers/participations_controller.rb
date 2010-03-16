class ParticipationsController < ApplicationController

  before_filter :load_event
  before_filter :load_event_participant, :only => [:show, :update]

  def index
    @event_participants = @event.event_participants.all
  end

  def new
    @event_participant = EventParticipant.new(:event => @event)
    unless @event.vacancies?
      flash[:error] = t('participations.new.no_vacancies')
      redirect_to event_path(@event)
    end
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

      flash[:notice] = t('participations.create.notice')
      redirect_to event_path(@event)
    else
      flash.now[:error] = t('participations.create.error')
      render :new
    end
  end

  def show
  end

  def update
    @event_participant.attributes = params[:event_participant]
    if @event_participant.valid?
      @event_participant.save
      flash[:notice] = t('participations.update.notice')
      redirect_to event_path(@event)
    else
      flash.now[:error] = t('participations.update.error')
      render :show
    end
  end

  private

  def load_event
    if action_name == 'index' and not @current_user
      redirect_to(root_path)
      return
    end

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
      redirect_to event_path(@event)
    end
  end
end
